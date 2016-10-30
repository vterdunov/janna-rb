$root = __dir__

require_relative 'config/app_init'
Dir["#{$root}/lib/rest_api/*.rb"].each { |f| require f }
