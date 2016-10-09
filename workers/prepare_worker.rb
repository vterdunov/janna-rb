class PrepareWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(jid)
    @jid = jid
    wait_for_job @jid
  end

  def wait_for_job(jid)
    # TODO: Not safety!
    while Sidekiq::Status.complete?(jid) == false
      puts "Waiting until #{jid} will be complete."
      sleep 1
    end
    puts "#{jid} complete."

    prepare jid
  end

  private

  def prepare(jid)
    j_data = Sidekiq::Status.get_all jid
    ova_path = j_data['ova_path']

    unpack_ova ova_path
    cleanup ova_path
  rescue
    [500, 'Prepare error']
  end

  def unpack_ova(ova_path)
    puts "Unpack OVA: #{ova_path}"
    t_dir = Dir.mktmpdir('janna-', '/tmp')
    `tar xf #{ova_path} -C #{t_dir}`
  end

  def cleanup(ova_path)
    ova_dir = File.dirname(ova_path)
    raise 'Cannot cleanup' unless File.readable?(ova_dir) && File.exist?(ova_dir)
    FileUtils.rm_rf ova_dir
  end
end
