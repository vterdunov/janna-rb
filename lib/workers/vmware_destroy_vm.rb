require_relative '../services/notifier'
require_relative '../services/downloader'
require_relative '../services/unpacker'
require_relative '../services/preparer_params'
require_relative '../services/providers/vmware'

class VMwareDestroyVM
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    strip_params = PreparerParams.new(params).prepare
    notify_options = { message_to: strip_params['message_to'] }
    notify = Notifier.new(notify_options)
    notify.slack(text: "Start destroy VM: `#{strip_params[:vmname]}`.")

    do_work(strip_params)
    notify.slack(text: "VM `#{strip_params[:vmname]}` has been destroyed.", message_level: 'good')
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    notify.slack(text: e.message, message_level: 'error')
  end

  def do_work(params)
    VMware.new(params).destroy_vm
  end
end
