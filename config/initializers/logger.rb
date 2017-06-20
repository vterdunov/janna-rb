logger = Logger.new(STDOUT)
logger.formatter = lambda do |severity, datetime, _progname, msg|
  "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{severity}: #{msg}\n"
end
logger.level = Logger::DEBUG

$logger = logger
