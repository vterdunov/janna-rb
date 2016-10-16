class VMWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(url)
    do_work url
  end

  def do_work(url)
    ova_path = Download.new(url).start
    Prepare.new(ova_path).start
  end
end
