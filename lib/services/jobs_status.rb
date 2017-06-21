class JobsStatus
  attr_reader :opts

  def initialize(opts)
    @opts = opts
  end

  def job_list
    res = {}
    workers = Sidekiq::Workers.new
    if workers.size.empty?
      res[:ok] = true
      res[:message] = 'No jobs enqueued at this moment'
      return res
    end

    res = fill_work_hash(workers)
    res
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    res[:ok] = false
    res[:error] = e.message
    res
  end

  def job_status(job_id)
    Sidekiq::Status.status(job_id)
  end

  private

  def fill_work_hash(workers)
    res = {}

    workers.each do |work|
      $logger.debug { "work=#{work}" }
      res[:ok] = true
      res[:jid] = work[:jid]
      res[:created_at] = work[:created_at]
      res[:enqueued_at] = work[:enqueued_at]
      res[:run_at] = work[:run_at]
    end
    res
  end
end
