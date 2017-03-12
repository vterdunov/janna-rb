class ApplicationController

  # Create VM from Template
  #
  # @param provider_type [String] *Required Hypervisor provider type. Possible values: `vmware`
  # @param vmname  [String] *Required Virtual Machine name
  # @param template_name [String] *Required Template name
  # @param template_path [String] *Optional Path to Templates folder
  # @param network [String] *Optional Network name
  # @param datacenter [String] *Optional Datacenter name
  # @param datastore [String] *Optional Datastore name
  # @param cluster [String] *Optional Cluster name
  # @param vm_folder [String] *Optional Folder name where VM will be created
  # @param message_to [String] *Optional Name or Channel to send messages
  #
  # @return 202 OK HTTP Response Code. Deploy VM in progress.
  post '/v1/template' do
    provider_worker.perform_async(vm_params)
    status 202
  end
end
