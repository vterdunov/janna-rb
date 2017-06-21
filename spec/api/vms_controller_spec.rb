RSpec.describe 'VmsController' do
  context 'POST /v1/vm' do
    subject { post 'v1/vm', args }

    context 'dummy' do
      let(:args) { { provider_type: 'dummy', vmname: 'testparam', address: 'testparam' } }
      it { expect(subject.status).to eq 202 }
    end
  end

  context 'PUT /v1/vm' do
    subject { put 'v1/vm', args }

    context 'dummy' do
      let(:args) { { provider_type: 'dummy', vmname: 'testparam', state: 'on' } }
      xit { expect(subject.status).to eq 200 }
    end
  end

  context 'DELETE /v1/vm' do
    subject { delete 'v1/vm', args }

    context 'dummy' do
      let(:args) { { provider_type: 'dummy', vmname: 'testparam' } }
      xit { expect(subject.status).to eq 202 }
    end
  end

  context 'GET /v1/vm' do
    subject { get 'v1/vm', args }

    context 'dummy' do
      let(:args) { { provider_type: 'dummy', vmname: 'testparam' } }
      xit { expect(subject.status).to eq 202 }
    end
  end
end
