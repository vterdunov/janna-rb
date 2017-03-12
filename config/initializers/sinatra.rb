require 'sinatra/base'
require 'redis'
require "#{$root}/lib/helpers/rest_helper"

class ApplicationController < Sinatra::Base
  configure do
    set :bind, '0.0.0.0'
    REDIS = Redis.new(url: ENV['REDIS_URI'])
  end

  helpers do
    include RestHelper
  end
end
