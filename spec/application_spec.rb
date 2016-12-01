RSpec.describe 'ApplicationController' do
  context 'GET /health' do
    subject { get '/health' }
    it { is_expected.to be_ok }
  end

  context 'POST /v1/vm' do
    subject { post 'v1/vm', args }
    let(:args) { { address: 'asdf', vmname: 'asdf', provider_type: 'dummy' } }
    it { expect(subject.status).to eq 202 }
  end
end
