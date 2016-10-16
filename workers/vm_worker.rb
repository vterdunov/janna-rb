class VMWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(url)
    do_work url
  end

  def do_work(url)
    yield(url) if block_given?
  end
end
