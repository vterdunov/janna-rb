source 'https://rubygems.org'

gem 'bundler'
gem 'dotenv'
gem 'rbvmomi'
gem 'sidekiq'
gem 'sinatra'
gem 'slack-notifier'
gem 'activesupport'

group :development do
  gem 'shotgun'
  gem 'yard'
  gem 'yard-sinatra'
  gem 'byebug'
end

group :test, :development do
  gem 'sqlite3'
end

group :test do
  gem 'rspec-sidekiq'
  gem 'webmock'
  gem 'rack-test'
  gem 'rspec'
end

group :production do
  gem 'puma'
end
