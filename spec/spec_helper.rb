require 'rack/test'
require 'rspec'
require 'webmock/rspec'
require 'byebug'

WebMock.disable_net_connect!(allow_localhost: true)

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../janna.rb', __FILE__

$logger.level = :fatal

FIXTURES_PATH = File.absolute_path("#{__dir__}/fixtures")

Dir["#{__dir__}/support/**/*.rb"].each { |s| require s }

module RSpecMixin
  include Rack::Test::Methods
  def app
    ApplicationController
  end
end

RSpec.configure { |c| c.include RSpecMixin }
