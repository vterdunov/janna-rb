source 'https://rubygems.org'

gem 'bundler'
gem 'sinatra'
gem 'sidekiq'
gem 'extracter'

group :development do
  gem 'shotgun'
end

group :test, :development do
  gem 'dotenv', '~> 2.0'
  gem 'sqlite3'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
end

group :production do
  gem 'puma'
end
