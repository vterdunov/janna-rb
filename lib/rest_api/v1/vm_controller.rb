class ApplicationController
  # Create VM from OVA file
  #
  # @param provider_type [String] *Required Hypervisor provider type. Possible values: `vmware`
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
    provider_worker.perform_async(vm_params)
    status 202
  end

  # Delete VM
  #
  # @param provider_type [String] *Required Hypervisor provider type. Possible values: `vmware`
  # @param vmname        [String]    *Required Virtual Machine name
  #
  # @return 202 Accepted. Destroy VM in progress.
  delete '/v1/vm' do
    provider_worker.perform_async(vm_params)
    status 202
  end

  # Get VM IP Address
  #
  # @param provider_type [String] *Required Hypervisor provider type. Possible values: `vmware`
  # @param vmname        [String] *Required Virtual Machine name. Will be searched on default VM folder
  # @param datacenter    [String] *Optional Datacenter name
  # @param vm_folder     [String] *Optional Folder name where VM will be created
  # @param message_to    [String] *Optional Name or Channel to send messages
  #
  # @return 200 OK, [Json] JSON with IP Addresses: {"nic0":["10.10.26.50","fe80::250:56ff:fe85:a155"],"nic1":[],"nic2":[]}
  get '/v1/vm' do
    provider_worker.new(vm_params).vm_ip.to_json
  end
end
