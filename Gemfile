source 'https://rubygems.org'

gem 'bundler'
gem 'sinatra'
gem 'sidekiq'
gem 'rbvmomi'
gem 'dotenv'

group :development do
  gem 'shotgun'
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
