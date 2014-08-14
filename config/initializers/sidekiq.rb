# encoding: utf-8

require 'sidekiq'
require 'sidekiq-status'
require 'traktim'


Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add(Sidekiq::Status::ClientMiddleware)
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add(Sidekiq::Status::ServerMiddleware, expiration: 5.minutes)
  end
  config.client_middleware do |chain|
    chain.add(Sidekiq::Status::ClientMiddleware)
  end
end
