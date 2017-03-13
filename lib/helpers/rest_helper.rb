require 'sidekiq'
require_relative '../workers/vmware/deploy_ova'
require_relative '../workers/vmware/destroy_vm'
require_relative '../workers/vmware/deploy_template'
require_relative '../services/providers/vmware/vm_ip'

Dummy = Struct.new(:perform_async, :new) do
  def perform_async(*args); end

  def new(*args); end
end

module RestHelper
  PROVIDER_TYPES = {
    ['vmware', 'post',   '/v1/vm']       => VMwareDeployOVA,
    ['vmware', 'delete', '/v1/vm']       => VMwareDestroyVM,
    ['vmware', 'get',    '/v1/vm']       => VMwareIP,
    ['vmware', 'post',   '/v1/template'] => VMwareDeployTemplate
  }

  def provider_worker
    PROVIDER_TYPES[[params[:provider_type], request.request_method.downcase, request.path_info.downcase]] || Dummy.new
  end

  # @return [Hash] params for executor-object
  def vm_params
    custom = params.each_with_object({}) do |(key, value), result|
      result[key.to_sym] = value.strip
    end
    $default_vm_params.merge(custom)
  end
end
