# require 'rubygems'
# require 'bundler/setup'
require 'sinatra/base'

Dir.glob('./app/{helpers,controllers}/*.rb').each { |file| require file }

run ApplicationController
# map('/') { run ApplicationController }
# map('/test') { run HealthController }
