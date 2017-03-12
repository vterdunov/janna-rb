module VmSpecHelper
  def stub_vm_deploy_params
    YAML.load(IO.read("#{FIXTURES_PATH}/vm_deploy_params.yml")).symbolize_keys
  end
end
