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
end

group :test, :development do
  gem 'sqlite3'
end

group :test do
  gem 'rack-test'
  gem 'rspec'
end

group :production do
  gem 'puma'
end
