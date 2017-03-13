source 'https://rubygems.org'

gem 'activesupport'
gem 'bundler'
gem 'dotenv'
gem 'rbvmomi'
gem 'sidekiq'
gem 'sinatra'
gem 'slack-notifier'

group :development do
  gem 'byebug'
  gem 'shotgun'
  gem 'yard'
  gem 'yard-sinatra'
end

group :test, :development do
  gem 'sqlite3'
end

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-sidekiq'
  gem 'webmock'
end

group :production do
  gem 'puma'
end
