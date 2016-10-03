class DownloadWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(url)
    @url = url
    total 100
    at 5, 'AT 5----------'
    store vino: 'veritas'
    download_ova_job(@url)
    vino = retrieve :vino
  end

  def download_ova_job(url)
    uri = URI(url)
    file_name = filename
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri
      http.request request do |response|
        open "/data/#{file_name}", 'w' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  rescue
    'Unexpected error'
  end

  def self.filename(url)
    uri = URI(url)
    File.basename(uri.path)
  end

  private

  def notify
    VirtualMachineCook.prepare_ova(filename)
  end

  def filename
    uri = URI(@url)
    File.basename(uri.path)
  end
end
