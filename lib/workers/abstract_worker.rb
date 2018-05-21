require_relative '../services/providers/rbvmomi_wrapper'

class AbstractWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false
  attr_reader :args

  def perform(args)
    @args = args.symbolize_keys!
    do_work(vim(args), datacenter(args), args)
  rescue RuntimeError => e
    catching(e)
  rescue StandardError => e
    catching(e, 'Something went wrong')
  end

  def vim(args)
    RbvmomiWrapper.vim(args)
  end

  def datacenter(args)
    RbvmomiWrapper.datacenter(args)
  end

  protected

  def do_work(_args)
    raise('Not implemented')
  end

  def catching(error, msg='')
    store stage: 'canceled'
    $logger.error { error.message }
    $logger.error { error.backtrace.join("\n\t") }
    message = msg.empty? ? error.message : msg
    $slacker.notify("Deploy error: #{message}",
      level: 'error',
      to: args[:message_to],
      footer: "VM: #{args[:vmname]}")
  end
end
