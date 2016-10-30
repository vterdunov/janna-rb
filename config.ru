require_relative 'janna'

map('/')       { run ApplicationController }
map('/health') { run HealthController }
map('/vm')     { run VmCreatorController }
