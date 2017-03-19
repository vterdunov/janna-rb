class ApplicationController
  # Create VM from Template
  #
  # @param [Hash] opts the options to create VM from Template
  # @option params [String] :provider_type  *Required Hypervisor provider type. Possible values: `vmware`
  # @option params [String] :vmname         *Required Virtual Machine name
  # @option params [String] :template_name  *Required Template name
  # @option params [String] :template_path  *Optional Path to Templates folder
  # @option params [String] :network        *Optional Network name
  # @option params [String] :datacenter     *Optional Datacenter name
  # @option params [String] :datastore      *Optional Datastore name
  # @option params [String] :cluster        *Optional Cluster name
  # @option params [String] :vm_folder      *Optional Folder name where VM will be created
  # @option params [String] :message_to     *Optional Name or Channel to send messages
  #
  # @return 202 Accepted. Deploy VM in progress.
  post '/v1/template' do
    provider_worker.perform_async(vm_params)
    status 202
  end
end
