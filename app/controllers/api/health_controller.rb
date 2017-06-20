class HealthController < ApplicationController
  # Application health
  #
  # @return 200 OK if Janna process is alive.

  get '/health' do
    content_type :json
    { ok: true }.to_json
  end
end
