RSpec.describe 'TemplatesController' do
  context 'POST /v1/template' do
    subject { post 'v1/template', args }
    let(:args) do
      { address: 'asdf',
        vmname: 'asdf',
        provider_type: 'dummy',
        template_name: 'test template' }
    end
    it { expect(subject.status).to eq 202 }
  end
end
