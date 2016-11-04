source 'https://rubygems.org'

gem 'bundler'
gem 'dotenv'
gem 'sinatra'
gem 'sidekiq'
gem 'rbvmomi'
gem 'slack-notifier'

group :development do
  gem 'shotgun'
  gem 'yard'
end

group :test, :development do
  gem 'sqlite3'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
end

group :production do
  gem 'puma'
end
