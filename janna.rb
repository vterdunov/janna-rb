require 'sinatra'
require 'uri'
require 'sidekiq'
require 'sidekiq-status'
require 'redis'
require 'tmpdir'
Dir['./workers/*.rb'].each { |file| require_relative file }

configure do
  set :bind, '0.0.0.0'
  REDIS = Redis.new(url: 'redis://redis:6379')

  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://redis:6379' }
    config.server_middleware do |chain|
      chain.add Sidekiq::Status::ServerMiddleware, expiration: 30 * 60 # default
    end
    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware, expiration: 30 * 60 # default
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://redis:6379' }
    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware, expiration: 30 * 60 # default
    end
  end
end

post '/vm' do
  vm = VirtualMachineCook.new(params[:address])
  vm.create_vm
end

get '/' do
  logger.info("loading data")
  'Janna'
end

get '/health' do
  200
end

class VirtualMachineCook
  attr_reader :jid

  def initialize(url)
    @url = url
    @jid = nil
  end

  def create_vm
    download_ova @url
    prepare_ova @jid
  end

  private

  def download_ova(url)
    jid = DownloadWorker.perform_async url
    DownloadWorker.filename url
    @jid = jid
  end

  def prepare_ova(jid)
    PrepareWorker.perform_async jid
  end
end
