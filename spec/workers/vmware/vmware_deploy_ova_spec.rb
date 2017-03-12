RSpec.xdescribe VMwareDeployOVA do
  include VmSpecHelper
  it { is_expected.to be_unique }
  context 'perform_async to be delayed' do
    subject { described_class.perform_async(params) }
    let(:params) { stub_vm_deploy_params }
    specify 'have enqueued job' do
      subject
      expect(described_class).to have_enqueued_job(params)
    end
  end
end
