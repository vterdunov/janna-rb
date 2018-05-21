require 'uri'
require 'tmpdir'
require 'down'

# Downloads files into temporary directory
#
# @example
#   # Create instance
#   file_url = 'https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64.ova'
#   file = Downloader.new(file_url)
#   # Start download file
#   file.download
class Downloader
  attr_reader :url

  def initialize(url)
    @url = url
  end

  # Starts download file
  # @return [String] Path to downloaded file
  def download
    Down.download(url).path
  rescue Down::Error => e
    $logger.error { e.message }
    raise "Failed download file: #{url}, error: #{e.message}"
  end
end
