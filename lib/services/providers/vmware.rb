require 'rbvmomi'
require 'rbvmomi/utils/deploy'
require 'rbvmomi/utils/admission_control'
require 'yaml'

class VMware
  attr_reader :ovf_path, :vm_name, :opts
  VIM = RbVmomi::VIM

  def initialize(ovf_path: '', vm_name: '', opts: {})
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
    $logger.info { 'Start deploy VM to VMware.' }
    vm = create_vm
    powerup_vm(vm)
  end

  def destroy
    $logger.info { 'Start destroy VM from VMware.' }
    vim ||= getting_vim
    dc           = datacenter(vim)
    vm           = getting_vm(dc, vm_name)
    begin
      vm.PowerOffVM_Task.wait_for_completion
    rescue RbVmomi::Fault
      $logger.debug { 'VM already powered off' }
    end
    begin
      vm.Destroy_Task.wait_for_completion
    rescue RbVmomi::Fault
      $logger.debug { "Failed to destroy the VM: #{vm_full_path}" }
      raise "ERROR: Failed to destroy the VM: #{vm_full_path}"
    end
  end

  private

  def create_vm
    vim ||= getting_vim
    dc        = datacenter(vim)
    vm_folder = get_vm_folder(dc)
    # vm        = getting_vm(dc, vm_name)
    scheduler = create_scheduler(vim, dc, vm_folder)

    scheduler.make_placement_decision
    datastore     = scheduler.datastore
    computer      = scheduler.pick_computer
    resource_pool = computer.resourcePool

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

    raise 'ERROR: No host in the cluster available to upload OVF to' unless host

    $logger.debug { 'Get networks' }
    network = computer.network.find { |x| x.name == opts[:network] }

    ovf = open(ovf_path, 'r') { |io| Nokogiri::XML(io.read) }
    ovf.remove_namespaces!
    networks = ovf.xpath('//NetworkSection/Network').map { |x| x['name'] }
    network_mappings = Hash[networks.map { |x| [x, network] }]

    network_mappings_str = network_mappings.map { |k, v| "#{k} = #{v.name}" }
    $logger.info { "Network: #{network_mappings_str.join(', ')}" }

    property_mappings = {}

    params = { vim: vim,
               ovf_path: ovf_path,
               vm_name: vm_name,
               vm_folder: vm_folder,
               host: host,
               resource_pool: resource_pool,
               datastore: datastore,
               network_mappings: network_mappings,
               property_mappings: property_mappings }

    ovf_deploy(params)
  end

  def getting_vim
    $logger.debug { 'Connect to VMware' }
    filtered_opts = opts.clone
    filtered_opts[:password] = 'SECRET'
    $logger.debug { "VMware options: #{filtered_opts}" }
    VIM.connect opts
  end

  def datacenter(vim)
    $logger.debug { 'Get datacenter' }
    vim.serviceInstance.find_datacenter(opts[:datacenter]) || raise('ERROR: Datacenter not found.')
  end

  def get_vm_folder(dc)
    $logger.debug { 'Get VM folder' }
    dc.vmFolder.traverse(opts[:vm_folder_path], VIM::Folder)
  end

  def create_scheduler(vim, dc, vm_folder)
    $logger.debug { 'Create scheduler' }
    AdmissionControlledResourceScheduler.new(
      vim,
      datacenter: dc,
      computer_names: [opts[:computer_path]],
      vm_folder: vm_folder,
      rp_path: '/',
      datastore_paths: [opts[:datastore]],
      max_vms_per_pod: nil, # No limits
      min_ds_free: nil, # No limits
    )
  end

  def getting_vm(datacenter, vm_name)
    vm_full_path = opts[:vm_folder_path] + '/' + vm_name
    datacenter.vmFolder.traverse(vm_full_path, VIM::VirtualMachine) || raise("ERROR: VM `#{vm_name}` not found.")
  end

  def ovf_deploy(vim: nil,
                 ovf_path: '',
                 vm_name: '',
                 vm_folder: nil,
                 host: nil,
                 resource_pool: nil,
                 datastore: nil,
                 network_mappings: nil,
                 property_mappings: nil)
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
  rescue RbVmomi::Fault => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    raise "ERROR: #{e.message}"
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
