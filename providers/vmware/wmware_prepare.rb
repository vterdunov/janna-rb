class WMwarePrepare
  def initialize(path)
    @path = path
  end

  def start
    unpack_ova @path
    cleanup @path
  rescue
    [500, 'Prepare error']
  end

  def unpack_ova(path)
    puts "Unpack OVA: #{path}"
    t_dir = Dir.mktmpdir('janna-', '/tmp')
    `tar xf #{path} -C #{t_dir}`
  end

  def cleanup(path)
    ova_dir = File.dirname(path)
    raise 'Cannot cleanup' unless File.readable?(ova_dir) && File.exist?(ova_dir)
    FileUtils.rm_rf ova_dir
  end
end
