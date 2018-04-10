class Unpacker
  def untar(file)
    t_dir = Dir.mktmpdir('janna-', '/tmp')
    $logger.debug { "Unpack file, src=#{file}, dest=#{t_dir}" }
    `tar xf #{file} -C #{t_dir}`
    t_dir
  end
end
