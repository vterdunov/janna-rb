require_relative '../../workers/vmware_deploy'
require_relative '../../workers/vmware_destroy'

class ApplicationController
  # Create VM
  #
  # @param provider_type [String] *Required Hypervisor provider type. Possible values: `vmware`
  # @param vmname  [String] *Required Virtual Machine name
  # @param ova_url [String] *Required URL to OVA file
  # @param vsphere_network [String] *Optional Network name
  # @param vsphere_datacenter [String] *Optional Datacenter name
  # @param vsphere_datastore [String] *Optional Datastore name
  # @param vsphere_cluster [String] *Optional Cluster name
  # @param vsphere_vm_folder [String] *Optional Folder name where VM will be created
  # @param message_to [String] *Optional Name or Channel to send messages
  #
  # @return 202 OK HTTP Response Code. Deploy VM in progress.
  post '/v1/vm' do
    case params[:provider_type]
    when 'vmware'
      $logger.info { "provider=vmware, params=#{params}" }
      VMwareDeploy.perform_async params
    when 'dummy'
      $logger.debug { "provider=dummy, params=#{params}" }
    else
      $logger.info { 'Undefined provider type. Halt request.' }
      halt 400, 'Undefined provider type.'
    end

    status 202
  end

  # List of VMs
  get '/v1/vm' do
    halt 400, 'Not implemented yet.'
  end

  # Delete VM
  delete '/v1/vm' do
    case params[:provider_type]
    when 'vmware'
      $logger.info { "provider=vmware, params=#{params}" }
      VMwareDestroy.perform_async params
    when 'dummy'
      $logger.debug { "provider=dummy, params=#{params}" }
    else
      $logger.info { 'Undefined provider type. Halt request.' }
      halt 400, 'Undefined provider type.'
    end

    status 202
  end
end
