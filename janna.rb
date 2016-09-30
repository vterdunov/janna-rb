require 'sinatra'
require 'uri'
require 'sidekiq'
require 'redis'
require_relative 'worker'

configure do
  set :bind, '0.0.0.0'
  REDIS = Redis.new(url: 'redis://redis:6379')

  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://redis:6379' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://redis:6379' }
  end
end

post '/vm' do
  create_vm params[:address]
end

get '/' do
  'Hello world!'
end

get '/health' do
  200
end

def create_vm(url)
  # download_ova url
  DownloadWorker.perform_async url
end
