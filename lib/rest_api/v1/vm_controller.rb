class ApplicationController
  # Create VM from OVA file
  #
  # @param [Hash] opts the options to create VM from OVA file
  # @option params [String] :provider_type *Required Hypervisor provider type. Possible values: `vmware`
  # @option params [String] :vmname        *Required Virtual Machine name
  # @option params [String] :ova_url       *Required URL to OVA file
  # @option params [String] :network       *Optional Network name
  # @option params [String] :datacenter    *Optional Datacenter name
  # @option params [String] :datastore     *Optional Datastore name
  # @option params [String] :cluster       *Optional Cluster name
  # @option params [String] :vm_folder     *Optional Folder name where VM will be created
  # @option params [String] :message_to    *Optional Name or Channel to send messages
  #
  # @return 202 Accepted. Deploy VM in progress.
  post '/v1/vm' do
    provider_worker.perform_async(vm_params)
    status 202
  end

  # Delete VM
  #
  # @param [Hash] opts the options to destroy VM
  # @option params [String] :provider_type *Required Hypervisor provider type. Possible values: `vmware`
  # @option params [String] :vmname        *Required Virtual Machine name
  #
  # @return 202 Accepted. Destroy VM in progress.
  delete '/v1/vm' do
    provider_worker.perform_async(vm_params)
    status 202
  end

  # Get VM IP Address
  #
  # @param [Hash] opts the options to get VM IP adresses
  # @option params [String] :provider_type *Required Hypervisor provider type. Possible values: `vmware`
  # @option params [String] :vmname        *Required Virtual Machine name. Will be searched on default VM folder
  # @option params [String] :datacenter    *Optional Datacenter name
  # @option params [String] :vm_folder     *Optional Folder name where VM will be created
  # @option params [String] :message_to    *Optional Name or Channel to send messages
  #
  # @return 200 OK, [Json] JSON with IP Addresses: {"nic0":["10.10.26.50","fe80::250:56ff:fe85:a155"],"nic1":[],"nic2":[]}
  get '/v1/vm' do
    provider_worker.new(vm_params).vm_ip.to_json
  end
end
