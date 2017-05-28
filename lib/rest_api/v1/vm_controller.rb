class ApplicationController
  # Create VM from OVA file
  #
  # @param provider_type [String] *Required Hypervisor provider type. Values: `vmware`
  # @param vmname        [String]    *Required Virtual Machine name
  # @param ova_url       [String]    *Required URL to OVA file
  # @param network       [String]    *Optional Network name
  # @param datacenter    [String]    *Optional Datacenter name
  # @param datastore     [String]    *Optional Datastore name
  # @param cluster       [String]    *Optional Cluster name
  # @param vm_folder     [String]    *Optional Folder name where VM will be created
  # @param message_to    [String]    *Optional Name or Channel to send messages
  #
  # @return 202 Accepted. Deploy VM in progress.
  post '/v1/vm' do
    rest_router.perform_async(vm_params)
    status 202
  end

  #  VM power management
  #
  # @param provider_type [String] *Required Hypervisor provider type. Values: `vmware`
  # @param vmname        [String] *Required Virtual Machine name. Will be searched on default VM folder
  # @param state         [String] *Required State of VM. Values: 'on|off|reset|suspend'
  # @param datacenter    [String] *Optional Datacenter name
  # @param vm_folder     [String] *Optional Folder name where VM placed
  #
  # @return 200 OK.
  put '/v1/vm' do
    content_type :json
    rest_router.new(vm_params).power_mgmt_vm.to_json
  end

  # Delete VM
  #
  # @param provider_type [String] *Required Hypervisor provider type. Values: `vmware`
  # @param vmname        [String] *Required Virtual Machine name
  #
  # @return 202 Accepted. Destroy VM in progress.
  delete '/v1/vm' do
    rest_router.perform_async(vm_params)
    status 202
  end

  # Get Information about Virtual machine
  #
  # @param provider_type [String] *Required Hypervisor provider type. Values: `vmware`
  # @param vmname        [String] *Required Virtual Machine name. Will be searched on default VM folder
  # @param datacenter    [String] *Optional Datacenter name
  # @param vm_folder     [String] *Optional Folder name where VM placed
  #
  # @return 200 OK, [Json] JSON with VM information about network and power state.
  get '/v1/vm' do
    content_type :json
    rest_router.new(vm_params).info.to_json
  end
end
