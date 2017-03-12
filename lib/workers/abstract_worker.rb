require_relative '../services/providers/vmware_wrapper'

class AbstractWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    do_work(vim(params), datacenter(params), params)
  rescue RuntimeError => e
    catching(e)
  end

  def vim(params)
    VMwareWrapper.vim(params)
  end

  def datacenter(params)
    VMwareWrapper.datacenter(params)
  end

  protected

  def do_work(params)
    raise('Not implemented')
  end

  def catching(error)
    $logger.error { error.message }
    $logger.error { error.backtrace.inspect }
    $slacker.notify(error.message, message_level: 'error')
  end
end
