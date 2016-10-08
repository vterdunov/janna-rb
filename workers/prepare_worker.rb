class PrepareWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(jid)
    @jid = jid
    wait_for_job @jid
  end

  def wait_for_job(jid)
    while Sidekiq::Status.complete?(jid) == false
      puts "waiting for #{jid} will be complete."
      sleep 1
    end
    puts "#{jid} complete"
    unpack_ova jid
  end

  def unpack_ova(jid)
    j_data = Sidekiq::Status.get_all jid
    ova_path = "/data/#{j_data['filename']}"
    puts ova_path
    begin
      dir = Dir.mktmpdir('janna-', '/tmp')
      `tar xf #{ova_path} -C #{dir}`
      if File.readable?(ova_path) && File.exist?(ova_path)
        File.delete ova_path
        200
      else
        [500, 'Unpack error']
      end
    end
  end
end
