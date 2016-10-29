require './config/environment'

map('/')       { run Application }
map('/health') { run HealthController }
map('/vm')     { run VmCreatorController }
