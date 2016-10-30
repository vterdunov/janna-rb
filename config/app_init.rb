require 'dotenv'
require 'logger'

Dotenv.load(
  File.expand_path("#{__dir__}/../.env.local", __FILE__),
  File.expand_path("#{__dir__}/../.env.#{ENV['RACK_ENV']}", __FILE__),
  File.expand_path("#{__dir__}/../.env", __FILE__)
)

Dir["#{$root}/config/initializers/*.rb"].each { |f| require f }

logger = Logger.new(STDOUT)
logger.formatter = lambda do |severity, datetime, _progname, msg|
  "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{severity}: #{msg}\n"
end

$logger = logger
