RSpec.describe 'ApplicationController' do
  context 'GET /health' do
    subject { get '/health' }
    it { is_expected.to be_ok }
  end

  context 'POST /vm' do
    subject { post 'vm', args }
    let(:args) { { address: 'asdf', vmname: 'asdf' } }
    it { expect(subject.status).to eq 202 }
  end
end
