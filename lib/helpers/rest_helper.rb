require 'sidekiq'
require_relative '../services/providers/dummy/dummy'
require_relative '../workers/vmware/deploy_ova'
require_relative '../workers/vmware/destroy_vm'
require_relative '../workers/vmware/deploy_template'
require_relative '../services/providers/vmware/info'
require_relative '../services/providers/vmware/power'

# Helper Module for REST API
module RestHelper
  HANDLERS = {
    ['vmware', 'post',   '/v1/vm']       => VMwareDeployOVA,
    ['vmware', 'delete', '/v1/vm']       => VMwareDestroyVM,
    ['vmware', 'put',    '/v1/vm']       => VMwarePower,
    ['vmware', 'get',    '/v1/vm']       => VMwareVMInfo,
    ['vmware', 'post',   '/v1/template'] => VMwareDeployTemplate
  }.freeze

  def rest_router
    request_handler = HANDLERS[[params[:provider_type], request.request_method.downcase, request.path_info.downcase]]
    $logger.info { "Request handler: #{request_handler}" }
    request_handler || Dummy.new
  end

  # @return [Hash] params for executor-object
  def vm_params
    custom = params.each_with_object({}) do |(key, value), result|
      result[key.to_sym] = value.strip
    end
    $default_vm_params.merge(custom)
  end
end
