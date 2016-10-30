require 'dotenv'

Dotenv.load(
  File.expand_path("#{__dir__}/../.env.local", __FILE__),
  File.expand_path("#{__dir__}/../.env.#{ENV['RACK_ENV']}", __FILE__),
  File.expand_path("#{__dir__}/../.env", __FILE__)
)

Dir["#{$root}/config/initializers/*.rb"].each { |f| require f }
