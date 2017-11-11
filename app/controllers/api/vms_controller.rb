class VmsController < ApplicationController
  # Create VM from OVA file.
  #
  # @param opts Request body.
  # @option opts [String] :provider_type +Required+ Hypervisor provider type. Values: `vmware`
  # @option opts [String] :vmname        +Required+ Virtual Machine name
  # @option opts [String] :ova_url       +Required+ URL to OVA file
  # @option opts [String] :network       +Optional+ Network name
  # @option opts [String] :datacenter    +Optional+ Datacenter name
  # @option opts [String] :datastores     +Optional+ Datastores names. Comma separated string. E.g.: datastore1, datastore2, datastore3
  # @option opts [String] :cluster       +Optional+ Cluster name
  # @option opts [String] :vm_folder     +Optional+ Folder name where VM will be created
  # @option opts [String] :message_to    +Optional+ Userame or Channel to send messages
  #
  # @example response
  #    {
  #      "ok": true,
  #      "job_id": "a36e856f9479a216c57b51f5"
  #    }
  #
  # @return [json]
  post '/v1/vm' do
    content_type :json
    job_id = rest_router.perform_async(vm_params)
    $slacker.notify("Start deploy VM: `#{vm_params[:vmname]}`",
                    to: vm_params[:message_to],
                    footer: "JID: #{job_id}")
    status 202
    { ok: true, job_id: job_id }.to_json
  end

  # VM power management
  #
  # @param opts Request body.
  # @option opts [String] :provider_type +Required+ Hypervisor provider type. Values: `vmware`
  # @option opts [String] :vmname        +Required+ Virtual Machine name. Will be searched on default VM folder
  # @option opts [String] :state         +Required+ State of VM. Values: 'on|off|reset|suspend'
  # @option opts [String] :datacenter    +Optional+ Datacenter name
  # @option opts [String] :vm_folder     +Optional+ Folder name where VM placed
  #
  # @return [json]
  put '/v1/vm' do
    content_type :json
    params = rest_router.new(vm_params)
    params.power_mgmt_vm.to_json
  end

  # Delete VM
  #
  # @param opts Request body.
  # @option opts [String] :provider_type +Required+ Hypervisor provider type. Values: `vmware`
  # @option opts [String] :vmname        +Required+ Virtual Machine name
  #
  # @return [json] 202 Accepted. Destroy VM in progress.
  delete '/v1/vm' do
    content_type :json
    job_id = rest_router.perform_async(vm_params)
    status 202
    { ok: true, job_id: job_id }.to_json
  end

  # Get Information about Virtual machine
  #
  # @param provider_type +Required+ Hypervisor provider type. Values: `vmware`
  # @param vmname        +Required+ Virtual Machine name. Will be searched on default VM folder
  # @param datacenter    +Optional+ Datacenter name
  # @param vm_folder     +Optional+ Folder name where VM placed
  #
  # @return [json] VM information about network and power state.
  get '/v1/vm' do
    content_type :json
    rest_router.new(vm_params).info.to_json
  end
end
