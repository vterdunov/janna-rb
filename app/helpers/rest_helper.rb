require_all 'lib'

# Helper Module for REST API
# @private
module RestHelper
  HANDLERS = {
    ['vmware', 'post',   '/v1/vm']       => VMwareDeployOVA,
    ['vmware', 'delete', '/v1/vm']       => VMwareDestroyVM,
    ['vmware', 'put',    '/v1/vm']       => VMwareVMPower,
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
      result[key.to_sym] = value.strip if value.respond_to?(:strip)
    end
    $default_vm_params.merge(custom)
  end
end
