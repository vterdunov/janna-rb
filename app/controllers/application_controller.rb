require 'sinatra/base'

class ApplicationController < Sinatra::Base
  helpers ApplicationHelper

  # configure do
    # set :bind, '0.0.0.0'
    # enable :logging

    # REDIS = Redis.new(url: ENV['REDIS_URI'])

    # Sidekiq.configure_server do |config|
    #   config.redis = { url: ENV['REDIS_URI'] }
    # end

    # Sidekiq.configure_client do |config|
    #   config.redis = { url: ENV['REDIS_URI'] }
    # end
  # end
end

