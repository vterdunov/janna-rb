require 'sinatra/base'
require 'bundler/setup'

require './app/helpers/application_helper.rb'
require './app/controllers/application_controller.rb'

Dir.glob("#{__dir__}/app/{controllers,helpers}/*.rb").each { |file| require file }

map('/')       { run ApplicationController }
map('/health') { run HealthController }
map('/vm')     { run VmCreatorController }
