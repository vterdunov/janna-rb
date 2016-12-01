require_relative '../services/notifier'
require_relative '../services/downloader'
require_relative '../services/unpacker'
require_relative '../services/providers/vmware'

class VMwareWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    strip_params = params.map { |key, value| [key, value.strip] }.to_h
    vmname = strip_params['vmname']
    ova_url = strip_params['ova_url']
    notify_options = { message_to: strip_params['message_to'] }
    notify = Notifier.new(notify_options)
    notify.slack "Start deploy VM: `#{vmname}`"
    ip = do_work(vmname, ova_url, strip_params)
    notify.slack "VM `#{vmname}` has been deployed. IP: #{ip}"
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    notify.slack e.message
  end

  def do_work(vmname, ova_url, params)
    ova_path = Downloader.new(ova_url).download
    tmp_dir  = Unpacker.new(ova_path).tar
    ovf_path = Dir["#{tmp_dir}/**/*.ovf"].first
    raise "ERROR: Cannot get OVF file for `#{vmname}`" unless ovf_path
    VMware.new(ovf_path, vmname, params).deploy
  end
end
