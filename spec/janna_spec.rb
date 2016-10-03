require File.expand_path '../spec_helper.rb', __FILE__

describe 'GET /' do
  context 'when try to accessing the home page' do
    it 'return 200' do
      get '/'

      expect(last_response).to be_ok
    end
  end
end

describe 'GET /health' do
  context 'when get healthcheck' do
    it 'return 200' do
      get '/health'

      expect(last_response).to be_ok
    end
  end
end
