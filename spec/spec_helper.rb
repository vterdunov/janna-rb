require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../janna.rb', __FILE__

$logger.level = :fatal

module RSpecMixin
  include Rack::Test::Methods
  def app
    ApplicationController
  end
end

RSpec.configure { |c| c.include RSpecMixin }
