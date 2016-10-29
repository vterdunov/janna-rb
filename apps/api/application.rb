require 'sinatra/base'
require 'redis'
require 'sidekiq'

Dir["#{__dir__}/helpers/*.rb"].each { |file| require_relative file }

class Application < Sinatra::Base
  helpers ApplicationHelper

  configure do
    set :bind, '0.0.0.0'
    enable :logging
    REDIS = Redis.new(url: ENV['REDIS_URI'])

    set vsphere_address:        ENV['VSPHERE_ADDRESS']
    set vsphere_username:       ENV['VSPHERE_USERNAME']
    set vsphere_password:       ENV['VSPHERE_PASSWORD']
    set vsphere_dc:             ENV['VSPHERE_DC']
    set vsphere_datastore:      ENV['VSPHERE_DATASTORE']
    set vsphere_network:        ENV['VSPHERE_NETWORK']
    set vsphere_template_path:  ENV['VSPHERE_TEMPLATE_PATH']
    set vsphere_computer_path:  ENV['VSPHERE_COMPUTER_PATH']
    set vsphere_vm_folder_path: ENV['VSPHERE_VM_FOLDER_PATH']

    set slack_webhook_url:  ENV['SLACK_WEBHOOK_URL']
    set slack_channel:      ENV['SLACK_CHANNEL']
    set slack_bot_username: ENV['SLACK_BOT_USERNAME']
  end
end

Dir["#{__dir__}/controllers/*.rb"].each { |file| require_relative file }
