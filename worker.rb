class DownloadWorker
  include Sidekiq::Worker

  def perform(url)
    download_ova url
  end

  def download_ova(url)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri
      http.request request do |response|
        open '/data/large.ova', 'w' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  rescue
    'Unexpected error'
  end
end
