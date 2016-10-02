class DownloadWorker
  include Sidekiq::Worker

  def perform(url)
    download_ova url
  end

  def download_ova(url)
    uri = URI(url)
    file_name = File.basename(uri.path)
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
end
