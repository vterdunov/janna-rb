ENV['SINATRA_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

Dotenv.load(
  File.expand_path("#{__dir__}/../.env.local", __FILE__),
  File.expand_path("#{__dir__}/../.env", __FILE__)
)

require 'active_support'
require 'active_support/core_ext'

require_all 'config/initializers'
require_all 'app'
require_all 'lib'
