class DownloadWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(url)
    @url = url
    ova_path = download_ova_job @url
    store ova_path: ova_path
  end

  def download_ova_job(url)
    uri = URI(url)
    f_name = filename url
    t_dir = mk_tmp_dir
    ova_path = "#{t_dir}/#{f_name}"
    puts "Start download #{f_name}"
    raise 'ERROR Temporary directory doesn\'t exist' unless File.exist? t_dir
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri
      http.request request do |response|
        open ova_path, 'w' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
    puts "File Downloaded: #{ova_path}"
    ova_path
  rescue StandardError => e
    puts e.message
    puts e.backtrace.inspect
  end

  def self.filename(url)
    uri = URI(url)
    File.basename(uri.path)
  end

  private

  def mk_tmp_dir
    Dir.mktmpdir('janna-tmp-download-', '/tmp')
  end

  def filename(url)
    uri = URI(url)
    File.basename(uri.path)
  end
end
