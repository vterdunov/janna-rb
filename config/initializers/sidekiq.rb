Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URI'] }
  config.server_middleware do |chain|
    # accepts :expiration (optional)
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 180.minutes # default
  end
  config.client_middleware do |chain|
    # accepts :expiration (optional)
    chain.add Sidekiq::Status::ClientMiddleware, expiration: 180.minutes # default
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URI'] }
  config.client_middleware do |chain|
    # accepts :expiration (optional)
    chain.add Sidekiq::Status::ClientMiddleware, expiration: 180.minutes # default
  end
end
