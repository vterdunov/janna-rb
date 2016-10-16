require 'sinatra'
require 'uri'
require 'sidekiq'
require 'redis'
require 'tmpdir'
require 'dotenv'

Dotenv.load(
  File.expand_path('../.env.local', __FILE__),
  File.expand_path("../.env.#{ENV['RACK_ENV']}", __FILE__),
  File.expand_path('../.env', __FILE__))

Dir['./providers/**/*.rb'].each { |file| require_relative file }

configure do
  set :bind, '0.0.0.0'
  REDIS = Redis.new(url: ENV['REDIS_URI'])

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_URI'] }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URI'] }
  end
end

# ----------------------------------------
post '/vm' do
  WMWareWorker.perform_async params[:address]
end

get '/' do
  logger.info('loading data')
  'Janna'
end

get '/health' do
  200
end
