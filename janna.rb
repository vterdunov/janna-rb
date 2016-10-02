require 'sinatra'
require 'uri'
require 'sidekiq'
require 'redis'
require 'extracter'
require_relative 'worker'
require 'tmpdir'

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
  'Janna'
end

get '/health' do
  200
end

def create_vm(url)
  ovafile = download_ova url
  prepare_ova ovafile
end

def download_ova(url)
  DownloadWorker.perform_async url
  DownloadWorker.filename url
end

def prepare_ova(ovafile)
  ova_path = "/data/#{ovafile}"
  begin
    dir = Dir.mktmpdir('janna-', '/tmp')
    Extracter.new(ova_path, dir)
    if File.readable?(ova_path) && File.exist?(ova_path)
      puts 'YES'*50
    else
      puts 'NO'*50
    end
  end
end
