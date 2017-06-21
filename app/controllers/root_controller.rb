class RootController < ApplicationController
  get '/' do
    erb :welcome
  end
end
