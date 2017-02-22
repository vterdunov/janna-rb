require_relative '../services/notifier'
require_relative '../services/downloader'
require_relative '../services/unpacker'
require_relative '../services/providers/vmware'

class VMwareDestroyVM
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    strip_params = params.map { |key, value| [key, value.strip] }.to_h
    vmname = strip_params['vmname']
    notify_options = { message_to: strip_params['message_to'] }
    notify = Notifier.new(notify_options)
    notify.slack(text: "Start destroy VM: `#{vmname}`.")
    do_work(vmname, strip_params)
    notify.slack(text: "VM `#{vmname}` has been destroyed.", message_level: 'good')
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    notify.slack(text: e.message, message_level: 'error')
  end

  def do_work(vmname, params)
    VMware.new(vm_name: vmname, opts: params).destroy_vm
  end
end
