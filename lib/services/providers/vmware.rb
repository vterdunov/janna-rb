require 'rbvmomi'
require 'rbvmomi/utils/deploy'
require 'rbvmomi/utils/admission_control'
require 'yaml'

class VMware
  attr_reader :ovf_path, :vm_name, :opts
  VIM = RbVmomi::VIM

  def initialize(ovf_path, vm_name, opts)
    @ovf_path = ovf_path
    @vm_name  = vm_name
    @opts     = defaults.merge(opts)
  end

  def defaults
    {
      host:           ENV['VSPHERE_ADDRESS'],
      port:           ENV['VSPHERE_PORT'],
      user:           ENV['VSPHERE_USERNAME'],
      password:       ENV['VSPHERE_PASSWORD'],
      datacenter:     ENV['VSPHERE_DC'],
      datastore:      ENV['VSPHERE_DATASTORE'],
      computer_path:  ENV['VSPHERE_CLUSTER'],
      network:        ENV['VSPHERE_NETWORK'],
      vm_folder_path: ENV['VSPHERE_VM_FOLDER'],
      path:           '/sdk',
      insecure:       true,
      ssl:            true,
      debug:          false
    }
  end

  def deploy
    filtered_opts = opts.clone
    filtered_opts[:password] = 'SECRET'
    $logger.debug { "VMware options: #{filtered_opts}" }
    # get resources
    $logger.debug { 'Get resources from vmware' }
    vim = VIM.connect opts
    dc = vim.serviceInstance.find_datacenter(opts[:datacenter])
    root_vm_folder = dc.vmFolder

    vm_folder = root_vm_folder.traverse(opts[:vm_folder_path], VIM::Folder)

    $logger.debug { 'Create scheduler' }
    scheduler = AdmissionControlledResourceScheduler.new(
      vim,
      datacenter: dc,
      computer_names: [opts[:computer_path]],
      vm_folder: vm_folder,
      rp_path: '/',
      datastore_paths: [opts[:datastore]],
      max_vms_per_pod: nil, # No limits
      min_ds_free: nil, # No limits
    )
    scheduler.make_placement_decision

    datastore = scheduler.datastore
    computer = scheduler.pick_computer
    rp = computer.resourcePool

    pc = vim.serviceContent.propertyCollector
    $logger.debug { 'Choose computer from cluster' }
    hosts = computer.host
    hosts_props = pc.collectMultiple(
      hosts,
      'datastore', 'runtime.connectionState',
      'runtime.inMaintenanceMode', 'name'
    )
    host = hosts.shuffle.find do |x|
      host_props = hosts_props[x]
      is_connected = host_props['runtime.connectionState'] == 'connected'
      is_ds_accessible = host_props['datastore'].member?(datastore)
      is_connected && is_ds_accessible && !host_props['runtime.inMaintenanceMode']
    end

    raise 'No host in the cluster available to upload OVF to' unless host

    $logger.debug { 'Get networks' }
    network = computer.network.find { |x| x.name == opts[:network] }

    ovf = open(ovf_path, 'r') { |io| Nokogiri::XML(io.read) }
    ovf.remove_namespaces!
    networks = ovf.xpath('//NetworkSection/Network').map { |x| x['name'] }
    network_mappings = Hash[networks.map { |x| [x, network] }]

    network_mappings_str = network_mappings.map { |k, v| "#{k} = #{v.name}" }
    puts "networks: #{network_mappings_str.join(', ')}"

    property_mappings = {}

    # -------------------------------------------------------------------------
    vm = ovf_deploy(vim, ovf_path, vm_name, vm_folder, host, rp, datastore, network_mappings, property_mappings)
    ip = powerup_vm vm
    ip
  end

  private

  def ovf_deploy(vim, ovf_path, vm_name, vm_folder, host, resource_pool, datastore, network_mappings, property_mappings)
    vim.serviceContent.ovfManager.deployOVF(
      uri: ovf_path,
      vmName: vm_name,
      vmFolder: vm_folder,
      host: host,
      resourcePool: resource_pool,
      datastore: datastore,
      networkMappings: network_mappings,
      propertyMappings: property_mappings
    )
  end

  def powerup_vm(vm)
    $logger.info 'Powering On VM ...'
    vm.PowerOnVM_Task.wait_for_completion

    until (ip = vm.guest_ip)
      sleep 5
      $logger.info 'Waiting for VM to be up ...'
    end

    $logger.info "VM got IP: #{ip}"

    ip
  end
end
