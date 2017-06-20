RSpec.describe 'HealthController' do
  context 'GET /health' do
    subject { get '/health' }
    it { is_expected.to be_ok }
  end
end
