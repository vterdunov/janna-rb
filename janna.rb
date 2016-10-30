require_relative 'config/app_init'
Dir['lib/rest_api/*.rb'].each { |f| require f }

map('/')       { run ApplicationController }
map('/health') { run HealthController }
map('/vm')     { run VmCreatorController }
