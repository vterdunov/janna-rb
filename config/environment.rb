require 'dotenv'
Dotenv.load(
  File.expand_path("#{__dir__}/../.env.local", __FILE__),
  File.expand_path("#{__dir__}/../.env.#{ENV['RACK_ENV']}", __FILE__),
  File.expand_path("#{__dir__}/../.env", __FILE__)
)

require 'sinatra/base'
require 'bundler/setup'
require 'sidekiq'
require 'redis'

require_relative '../lib/janna'
require_relative '../apps/api/application'
require_relative './sidekiq'
