require_all 'app/helpers'

class ApplicationController < Sinatra::Base
  configure do
    set :bind, '0.0.0.0'
    set :public_folder, 'public'
    set :views, 'app/views'

    helpers RestHelper
  end
end
