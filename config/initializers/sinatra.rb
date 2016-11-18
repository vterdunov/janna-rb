require 'sinatra/base'
require 'redis'

class ApplicationController < Sinatra::Base
  configure do
    set :bind, '0.0.0.0'
    REDIS = Redis.new(url: ENV['REDIS_URI'])
  end
end
