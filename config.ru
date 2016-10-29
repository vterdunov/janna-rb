require 'dotenv'
Dotenv.load(
  File.expand_path('../.env.local', __FILE__),
  File.expand_path("../.env.#{ENV['RACK_ENV']}", __FILE__),
  File.expand_path('../.env', __FILE__))

require 'sinatra/base'
require 'bundler/setup'

require './app/helpers/application_helper.rb'
require './app/controllers/application_controller.rb'

Dir.glob("#{__dir__}/app/{controllers,helpers,lib}/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/lib/**/*.rb").each { |file| require file }

require 'sidekiq'
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URI'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URI'] }
end

map('/')       { run ApplicationController }
map('/health') { run HealthController }
map('/vm')     { run VmCreatorController }
