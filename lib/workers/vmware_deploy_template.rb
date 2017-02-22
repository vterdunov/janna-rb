require_relative '../services/notifier'
require_relative '../services/downloader'
require_relative '../services/unpacker'
require_relative '../services/providers/vmware'

class VMwareDeployTemplate
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    strip_params = params.map { |key, value| [key, value.strip] }.to_h
    vmname = strip_params['vmname']
    template_name = strip_params['template_name']
    notify_options = { message_to: strip_params['message_to'] }
    notify = Notifier.new(notify_options)
    notify.slack(text: "Start deploy VM: `#{vmname}` from template: `#{template_name}`")
    ip = do_work(vmname, template_name, strip_params)
    notify.slack(text: "VM `#{vmname}` has been deployed. IP: #{ip}", message_level: 'good')
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    notify.slack(text: e.message, message_level: 'error')
  end

  def do_work(vmname, template_name, params)
    raise "ERROR: VM `#{vmname}` already exists." if VMware.new(vm_name: vmname).vm_exist?
    VMware.new( vm_name: vmname, template_name: template_name, opts: params).deploy_from_template
  end
end
