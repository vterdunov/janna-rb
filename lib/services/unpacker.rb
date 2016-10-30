class Unpacker
  def initialize(path)
    @path = path
  end

  def tar
    tmp_dir = unpack @path
    cleanup @path
    tmp_dir
  rescue
    [500, 'Prepare error']
  end

  def unpack(path)
    t_dir = Dir.mktmpdir('janna-', '/tmp')
    $logger.debug { "Unpack file, src=#{path}, dest=#{t_dir}" }
    `tar xf #{path} -C #{t_dir}`
    t_dir
  end

  def cleanup(path)
    dir_name = File.dirname(path)
    raise 'Cannot cleanup' unless File.readable?(dir_name) && File.exist?(dir_name)
    FileUtils.rm_rf dir_name
  end
end
