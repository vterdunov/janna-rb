class ApplicationController
  # Show application health
  #
  # @return The 200 OK HTTP Response Code if Janna process is alive
  get '/health' do
    200
  end
end
