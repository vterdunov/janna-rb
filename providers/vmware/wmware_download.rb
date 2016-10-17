class WMwareDownload
  def initialize(url)
    @url = url
  end

  def start
    uri = URI @url
    f_name = filename @url
    t_dir = mk_tmp_dir
    ova_path = "#{t_dir}/#{f_name}"
    puts "Start download #{f_name} from #{@url}"
    raise 'ERROR Temporary directory doesn\'t exist' unless File.exist? t_dir
    download uri, ova_path
    puts "File Downloaded: #{ova_path}"

    ova_path
  rescue StandardError => e
    puts 'ERROR'
    puts e.message
    puts e.backtrace.inspect
  end

  private

  def mk_tmp_dir
    Dir.mktmpdir('janna-tmp-download-', '/tmp')
  end

  def filename(url)
    uri = URI(url)
    File.basename(uri.path)
  end

  def download(uri, path)
    Net::HTTP.start(uri.host, uri.port) do |http|
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
