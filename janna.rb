require 'sinatra'
require 'uri'
require 'sidekiq'
require 'redis'
require 'tmpdir'
require_relative 'download'
require_relative 'prepare'
Dir['./workers/*.rb'].each { |file| require_relative file }

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
  vm = VirtualMachineCook.new(params[:address])
  vm.create_vm
end

get '/' do
  logger.info('loading data')
  'Janna'
end

get '/health' do
  200
end

class VirtualMachineCook
  def initialize(url)
    @url = url
  end

  def create_vm
    VMWorker.perform_async @url
  end
end
