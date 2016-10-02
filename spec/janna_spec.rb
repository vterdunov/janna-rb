require File.expand_path '../spec_helper.rb', __FILE__

describe "Janna application" do
  it 'should allow accessing the home page' do
    get '/'

    expect(last_response).to be_ok
  end

  it 'should be ok on health check' do
    get '/health'

    expect(last_response).to be_ok
  end
end
