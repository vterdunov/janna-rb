class PrepareWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(jid)
    @jid = jid
    wait_for_job @jid
  end

  def wait_for_job(jid)
    puts Sidekiq::Status.complete?(jid)
    while Sidekiq::Status.complete?(jid) == false
      puts "waiting for #{jid} will be complete."
      sleep 1
    end
    puts Sidekiq::Status.complete?(jid)
    puts "#{jid} complete"
    unpack_ova jid
  end

  def unpack_ova(jid)
    j_data = Sidekiq::Status.get_all jid
    ova_path = j_data['ova_path']
    ova_dir = File.dirname(ova_path)
    puts "OVA_PATH: #{ova_path} OVA_DIR: #{ova_dir}"
    begin
      dir = Dir.mktmpdir('janna-', '/tmp')
      `tar xf #{ova_path} -C #{dir}`
      if File.readable?(ova_dir) && File.exist?(ova_dir)
        # FileUtils.rm_rf ova_dir
        200
      else
        [500, 'Unpack error']
      end
    end
  end
end
