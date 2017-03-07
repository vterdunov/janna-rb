require_relative '../services/notifier'
require_relative '../services/downloader'
require_relative '../services/unpacker'
require_relative '../services/preparer_params'
require_relative '../services/providers/vmware'

class VMwareDeployOVA
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    strip_params = PreparerParams.new(params).prepare
    notify_options = { message_to: strip_params['message_to'] }
    notify = Notifier.new(notify_options)
    notify.slack(text: "Start deploy VM: `#{strip_params[:vmname]}`")

    ip = do_work(strip_params)
    notify.slack(text: "VM `#{strip_params[:vmname]}` has been deployed. IP: #{ip}", message_level: 'good')
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    notify.slack(text: e.message, message_level: 'error')
  end

  def do_work(params)
    raise "ERROR: VM `#{params[:vmname]}` already exists." if VMware.new(params).vm_exist?
    ova_path = Downloader.new(params[:ova_url]).download
    tmp_dir  = Unpacker.new(ova_path).tar
    params[:ovf_path] = Dir["#{tmp_dir}/**/*.ovf"].first
    raise "ERROR: Cannot get OVF file for `#{vmname}`" unless params[:ovf_path]
    VMware.new(params).deploy_ova
  end
end
