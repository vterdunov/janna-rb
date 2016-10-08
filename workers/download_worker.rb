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
    file_name = filename
    tmp_file = "#{tmp_dir}/#{file_name}"
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri
      http.request request do |response|
        open tmp_file, 'w' do |io|
          response.read_body do |chunk|
            io.write chunk
            puts 'waiting...'
          end
        end
      end
    end
    puts "File Downloaded: #{tmp_file}"
    tmp_file
  rescue
    'Unexpected error'
  end

  def self.filename(url)
    uri = URI(url)
    File.basename(uri.path)
  end

  private

  def tmp_dir
    Dir.mktmpdir('janna-tmp-download-', '/tmp')
  end

  def filename
    uri = URI(@url)
    File.basename(uri.path)
  end
end
