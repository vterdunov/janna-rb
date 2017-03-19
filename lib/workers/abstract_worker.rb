require_relative '../services/providers/rbvmomi_wrapper'

# @abstract Subclass and override {#do_work} to implement
#   a custom Worker class.
class AbstractWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  attr_reader :args

  def perform(args)
    @args = args.symbolize_keys!
    do_work(vim(args), datacenter(args), args)
  rescue RuntimeError => e
    catching(e)
  end

  def vim(args)
    RbvmomiWrapper.vim(args)
  end

  def datacenter(args)
    RbvmomiWrapper.datacenter(args)
  end

  protected

  def do_work(_args)
    raise NotImplementedError
  end

  def catching(error)
    $logger.error { error.message }
    $logger.error { error.backtrace.inspect }
    $slacker.notify(error.message, level: 'error', to: args[:message_to])
  end
end
