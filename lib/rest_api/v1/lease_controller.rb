class ApplicationController
  # Show expired VMs
  #
  # @param [Hash] opts the options to show expired VMs
  # @option params [String] :provider_type *Required Hypervisor provider type. Possible values: `vmware`
  # @option params [String] :datacenter    *Optional Datacenter name
  # @option params [String] :datastore     *Optional Datastore name
  # @option params [String] :cluster       *Optional Cluster name
  # @option params [String] :vm_folder     *Optional Folder name where VM will be created
  # @option params [String] :message_to    *Optional Name or Channel to send messages
  #
  # @return 200 OK HTTP Response Code. Show expired VMs
  get '/v1/lease/expired' do
    provider_worker.new(vm_params).expired
  end

  # Show soon expired VMs
  #
  # @param [Hash] opts the options to show soon expired VMs
  # @option params [String] :provider_type *Required Hypervisor provider type. Possible values: `vmware`
  # @option params [String] :datacenter    *Optional Datacenter name
  # @option params [String] :datastore     *Optional Datastore name
  # @option params [String] :cluster       *Optional Cluster name
  # @option params [String] :vm_folder     *Optional Folder name where VM will be created
  # @option params [String] :message_to    *Optional Name or Channel to send messages
  #
  # @return 200 OK HTTP Response Code. Show expired VMs
  # get '/v1/lease/soon_expired' do
  #   case params[:provider_type]
  #   when 'vmware'
  #     $logger.info { "provider=vmware, params=#{params}" }
  #     VMwareLease.perform_async params
  #   when 'dummy'
  #     $logger.debug { "provider=dummy, params=#{params}" }
  #   else
  #     $logger.info { 'Undefined provider type. Halt request.' }
  #     halt 400, 'Undefined provider type.'
  #   end

  #   status 200
  # end
end
