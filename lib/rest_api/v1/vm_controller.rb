require_relative '../../workers/vmware_deploy_ova'
require_relative '../../workers/vmware_destroy_vm'
require_relative '../../services/preparer_params'
require_relative '../../services/providers/vmware/vmware_vm'

class ApplicationController
  # Create VM from OVA file
  #
  # @param provider_type [String] *Required Hypervisor provider type. Possible values: `vmware`
  # @param vmname     [String] *Required Virtual Machine name
  # @param ova_url    [String] *Required URL to OVA file
  # @param network    [String] *Optional Network name
  # @param datacenter [String] *Optional Datacenter name
  # @param datastore  [String] *Optional Datastore name
  # @param cluster    [String] *Optional Cluster name
  # @param vm_folder  [String] *Optional Folder name where VM will be created
  # @param message_to [String] *Optional Name or Channel to send messages
  #
  # @return 202 OK HTTP Response Code. Deploy VM in progress.
  post '/v1/vm' do
    case params[:provider_type]
    when 'vmware'
      $logger.info { "provider=vmware, params=#{params}" }
      VMwareDeployOVA.perform_async params
    when 'dummy'
      $logger.debug { "provider=dummy, params=#{params}" }
    else
      $logger.info { 'Undefined provider type. Halt request.' }
      halt 400, 'Undefined provider type.'
    end

    status 202
  end

  # Delete VM
  delete '/v1/vm' do
    case params[:provider_type]
    when 'vmware'
      $logger.info { "provider=vmware, params=#{params}" }
      VMwareDestroyVM.perform_async params
    when 'dummy'
      $logger.debug { "provider=dummy, params=#{params}" }
    else
      $logger.info { 'Undefined provider type. Halt request.' }
      halt 400, 'Undefined provider type.'
    end

    status 202
  end

  # Get VM IP Address
  #
  # @param provider_type [String] *Required Hypervisor provider type. Possible values: `vmware`
  # @param vmname     [String] *Required Virtual Machine name
  # @param datacenter [String] *Optional Datacenter name
  # @param vm_folder  [String] *Optional Folder name where VM will be created
  # @param message_to [String] *Optional Name or Channel to send messages
  #
  # @return 200 OK HTTP Response Code.
  get '/v1/vm' do
    case params[:provider_type]
    when 'vmware'
      $logger.info { "provider=vmware, params=#{params}" }
      strip_params = PreparerParams.new(params).prepare
      ips = VMwareVM.new(strip_params).vm_ip
    when 'dummy'
      $logger.debug { "provider=dummy, params=#{params}" }
    else
      $logger.info { 'Undefined provider type. Halt request.' }
      halt 400, 'Undefined provider type.'
    end
    [200, ips]
  end
end
