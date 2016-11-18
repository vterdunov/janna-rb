require_relative '../../workers/vmware_worker'

class ApplicationController
  # Create VM
  #
  # @param provider_type [String] *Required Type of Hypervisor provider.
  # @param vmname  [String] *Required Name of Virtual Machine
  # @param ova_url [String] *Required URL to OVA file
  # @param vsphere_network [String] *Optional
  # @param vsphere_datacenter [String] *Optional
  # @param vsphere_datastore [String] *Optional
  # @param vsphere_network [String] *Optional
  # @param vsphere_cluster [String] *Optional
  # @param vsphere_vm_folder [String] *Optional
  #
  # @return 202 OK HTTP Response Code. Deploy VM in progress.
  post '/v1/vm' do
    case params[:provider_type]
    when 'vmware'
      $logger.info { "provider=vmware, params=#{params}" }
      VMwareWorker.perform_async params
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
    halt 400, 'Not implemented yet.'
  end
end
