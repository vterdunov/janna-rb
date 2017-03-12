RSpec.describe VMware do
  include VmSpecHelper
  context '.new' do
    subject { described_class.new(params) }
    let(:params) { {} }
    it { is_expected.to be_an_instance_of(described_class) }
  end

  context 'instance_methods' do
    subject(:vmware) { described_class.new(params) }

    context '#deploy_ova' do
      subject { vmware.deploy_ova }
      let(:params) { stub_vm_deploy_params }
      it { is_expected.to be_an_instance_of(String) }
    end
  end
end
