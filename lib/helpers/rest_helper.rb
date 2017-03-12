require_relative '../workers/vmware/vmware_deploy_ova'
require_relative '../workers/vmware/vmware_destroy_vm'
require_relative '../workers/vmware/vmware_deploy_template'
require_relative '../services/providers/vmware/vmware_vm'

Dummy = Struct.new(:perform_async, :new) do
  def perform_async(*asdf); end
  def new(*asdf); end
end

module RestHelper
  VM_PARAMS = %i(vmname ova_url network datacenter datastore cluster vm_folder message_to)

  PROVIDER_TYPES = {
    ['vmvare', 'post',   '/v1/vm']       => VMwareDeployOVA,
    ['vmvare', 'delete', '/v1/vm']       => VMwareDestroyVM,
    ['vmvare', 'get',    '/v1/vm']       => VMwareVM,
    ['vmvare', 'post',   '/v1/template'] => VMwareDeployTemplate
  }

  def provider_worker
    PROVIDER_TYPES[[params[:provider_type], params[:action], params[:path]]] || Dummy.new
  end

  # @return [Hash] params for executor-object
  def vm_params
    custom = params.slice(*VM_PARAMS).each_with_object({}) do |(key, value), result|
      result[key.to_sym] = value.strip
    end
    $default_vm_params.merge(custom)
  end
end
