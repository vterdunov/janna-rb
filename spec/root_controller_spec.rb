RSpec.describe 'RootController' do
  context 'GET /' do
    subject { get '/' }
    it { is_expected.to be_ok }
  end
end

RSpec.feature 'Main Page' do
  it 'responds with a Janna name' do
    get '/'
    expect(last_response.body).to include('Janna')
  end
end
