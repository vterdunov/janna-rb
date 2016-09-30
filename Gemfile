source 'https://rubygems.org'

gem 'bundler'
gem 'sinatra'
gem 'sidekiq'

group :development do
  gem 'shotgun'
end

group :test, :development do
  gem 'dotenv', '~> 2.0'
  gem 'sqlite3'
end

group :test do
  gem 'rspec'
end

group :production do
  gem 'puma'
end
