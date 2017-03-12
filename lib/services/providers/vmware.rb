require 'rbvmomi'
require 'rbvmomi/utils/deploy'
require 'rbvmomi/utils/admission_control'
require 'yaml'
require_relative 'vmware_wrapper'

class VMware
  attr_reader :ovf_path, :vm_name, :template_name, :opts, :vim, :datacenter
  # TODO: Researh about the constant.
  VIM = RbVmomi::VIM

  def initialize(vim, datacenter, opts = {})
    @vim = vim
    @datacenter = datacenter
    @ovf_path      = opts[:ovf_path]
    @vm_name       = opts[:vmname]
    @template_name = opts[:template_name]
    @opts          = opts
  end

  def deploy_ova
    $logger.info { 'Start deploy VM from OVA to VMware' }
    vm = create_vm
    powerup_vm(vm)
  end

  def deploy_from_template
    $logger.info { 'Start deploy VM from Template to VMware' }
    dc = datacenter
    vm_folder = get_vm_folder(dc)
    scheduler = create_scheduler(vim, dc, vm_folder)

    scheduler.make_placement_decision
    datastore       = scheduler.datastore
    computer        = scheduler.pick_computer
    network         = computer.network.find { |x| x.name == opts[:network] }
    root_vm_folder  = dc.vmFolder
    template_folder = root_vm_folder.traverse!(opts[:vm_folder_path], VIM::Folder)

    deployer = CachedOvfDeployer.new(
      vim, network, computer, template_folder, vm_folder, datastore
    )

    (template = vim.serviceInstance.find_datacenter.find_vm("#{opts[:template_path]}/#{template_name}")) ||
      abort('Template Not Found!')
    config = {}
    vm = deployer.linked_clone template, vm_name, config

    powerup_vm(vm)
  end

  def destroy_vm
    $logger.info { 'Start destroy VM from VMware' }
    dc           = datacenter
    vm           = getting_vm(dc, vm_name) || raise("ERROR: VM `#{vm_name}` not found.")
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

  def vm_exist?
    $logger.info { 'Check if VM already exists' }
    dc = datacenter
    getting_vm(dc, vm_name)
  end

  private

  def create_vm
    dc        = datacenter
    vm_folder = get_vm_folder(dc)
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
    datacenter.vmFolder.traverse(vm_full_path, VIM::VirtualMachine)
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
    $logger.info 'Powering On VM...'
    vm.PowerOnVM_Task.wait_for_completion

    until (ip = vm.guest_ip)
      sleep 5
      $logger.info 'Waiting for VM to be up...'
    end

    $logger.info "VM got IP: #{ip}"

    ip
  end
end
