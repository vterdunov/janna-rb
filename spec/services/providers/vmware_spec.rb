RSpec.describe VMware do
  include VmSpecHelper
  context '.new' do
    subject { described_class.new(vim, datacenter, params) }
    let(:params) { {} }
    let(:vim) { nil }
    let(:datacenter) { nil }
    it { is_expected.to be_an_instance_of(described_class) }
  end
end
