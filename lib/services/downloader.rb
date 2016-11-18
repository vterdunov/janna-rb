require 'uri'
require 'tmpdir'

# Downloads files into temporary directory
#
# @example
#   # Create instance
#   file_url = 'https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64.ova'
#   file = Downloader.new(file_url)
#   # Start download file
#   file.download
class Downloader
  def initialize(url)
    @url = url
  end

  # Starts download file
  # @return [String] Path to downloaded file
  def download
    uri = URI @url
    f_name = filename @url
    t_dir = mk_tmp_dir
    ova_path = "#{t_dir}/#{f_name}"
    $logger.debug { "Start download file, name=#{f_name}, url=#{@url}" }
    raise FileNotFoundException, 'ERROR Temporary directory doesn\'t exist' unless File.exist? t_dir
    download_file uri, ova_path
    raise FileNotFoundException, 'File not downloaded!' unless File.exist? ova_path
    $logger.debug { "File downloaded, path=#{ova_path}" }

    ova_path
  rescue StandardError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    raise 'ERROR: Failed download file.'
  end

  private

  # Creates temporary directory in /tmp with `janna-tmp-download-` prefix
  #
  # @return [String] Path to temporary directory
  def mk_tmp_dir
    Dir.mktmpdir('janna-tmp-download-', '/tmp')
  end

  # Returns name of file from URL string
  # @param url [Sting] The URL of the file
  # @example
  #   ova_url = 'https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64.ova'
  #   filname(ova_url) #=> ubuntu-16.04-server-cloudimg-amd64.ova
  #
  # @return [String] Base name of file
  def filename(url)
    uri = URI(url)
    File.basename(uri.path)
  end

  # Downloads file
  # @param uri [String] The URL of the file
  # @param path [String] Filename to save file
  def download_file(uri, path)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      http.request request do |response|
        open path, 'w' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  end
end
