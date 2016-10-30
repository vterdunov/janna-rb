require 'dotenv'

Dotenv.load(
  File.expand_path("#{__dir__}/../.env.local", __FILE__),
  File.expand_path("#{__dir__}/../.env.#{ENV['RACK_ENV']}", __FILE__),
  File.expand_path("#{__dir__}/../.env", __FILE__)
)

Dir['./initializers'].each { |f| require f }
