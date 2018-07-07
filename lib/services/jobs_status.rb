require 'sidekiq/api'

class JobsStatus
  attr_reader :opts

  def initialize(opts)
    @opts = opts
  end

  # @return [Hash] Active jobs.
  def job_list
    jobs = {}
    workers = Sidekiq::Workers.new
    if workers.size.zero?
      jobs[:ok] = true
      jobs[:message] = 'No jobs enqueued at this moment'
      return jobs
    end

    jobs[:jobs] = parse_jobs(workers)
    jobs[:ok] = true
    jobs
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.join("\n\t") }
    jobs[:ok] = false
    jobs[:error] = e.message
    jobs
  end

  # @param [String] Job ID
  # @return [Hash]  Job info by ID.
  def job_status(job_id)
    job = {}

    # :queued, :working, :complete, :failed or :interrupted, nil after expiry
    status = Sidekiq::Status.status(job_id)
    job[:status] = if status.nil?
                      'Unknown status. Job expired or never existed.'
                   else
                     status
                   end
    stage = Sidekiq::Status.get(job_id, :stage)
    job[:stage] = stage unless stage.blank?

    ip = Sidekiq::Status.get(job_id, :ip)
    job[:ip] = ip unless ip.blank?

    error = Sidekiq::Status.get(job_id, :error)
    if !error.blank?
      job[:error] = error
      job[:ok] = false
      return job
    end

    job[:ok] = true
    job
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.join("\n\t") }
    job[:ok] = false
    job[:error] = e.message
    job
  end

  private

  def parse_jobs(workers)
    jobs = []

    workers.each do |_, _, work|
      job = {}
      job[:jid]         = work['payload']['jid']
      job[:created_at]  = Time.at(work['payload']['created_at'])
      job[:enqueued_at] = Time.at(work['payload']['enqueued_at'])
      job[:run_at]      = Time.at(work['run_at'])
      jobs << job
    end
    jobs
  end
end
