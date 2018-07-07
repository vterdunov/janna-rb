require 'rbvmomi'
require 'rbvmomi/utils/deploy'
require 'rbvmomi/utils/admission_control'
require 'yaml'
require_relative '../rbvmomi_wrapper'

class VMware
  attr_reader :ovf_path, :vm_name, :template_name, :opts, :vim, :datacenter
  attr_accessor :scheduler
  # TODO: Researh about the constant.
  VIM = RbVmomi::VIM

  def initialize(vim, datacenter, opts = {})
    @vim           = vim
    @datacenter    = datacenter
    @ovf_path      = opts[:ovf_path]
    @vm_name       = opts[:vmname]
    @template_name = opts[:template_name]
    @opts          = opts
  end

  def deploy_from_template
    dc = datacenter
    vm_folder = get_vm_folder(dc)
    scheduler_opts = {
      vim: vim,
      dc: dc,
      vm_folder: vm_folder,
      computer_names: [opts[:computer_path]],
      datastore_paths: opts[:datastores],
    }
    scheduler = create_scheduler(scheduler_opts)

    # make_placement_decision call 'datacenter' method with can rase a RuntimeError. I need a recognize with type of errors was raised.
    # see: https://github.com/vmware/rbvmomi/blob/2e427817735e5df0aef1baa07bc95762e45a18bc/lib/rbvmomi/utils/admission_control.rb#L124
    begin
      scheduler.make_placement_decision
    rescue RuntimeError => e
      $logger.error { e.message }
      # Datastore not found
      ds_not_found = e.message.include?('datastore') && e.message.include?('not found')
      if ds_not_found
        raise e.message if opts[:datastores].size <= 1
        $logger.warn { 'Datastore not found. Retrying with new datastores.' }
        # grab ds from error
        bad_ds =  e.message.split(' ')[-3]
        opts[:datastores] = opts[:datastores] - [bad_ds]
        scheduler_opts[:datastore_paths] = opts[:datastores]
        scheduler = create_scheduler(scheduler_opts)
        retry
      end
    end

    datastore       = scheduler.datastore
    computer        = scheduler.pick_computer
    network         = computer.network.find { |x| x.name == opts[:network] }
    root_vm_folder  = dc.vmFolder
    template_folder = root_vm_folder.traverse!(opts[:vm_folder], VIM::Folder)

    deployer = CachedOvfDeployer.new(
      vim, network, computer, template_folder, vm_folder, datastore
    )

    (template = vim.serviceInstance.find_datacenter.find_vm("#{opts[:template_path]}/#{template_name}")) ||
      abort('Template Not Found!')
    config = {}
    deployer.linked_clone(template, vm_name, config)
  end

  def destroy_vm
    $logger.info { 'Start destroy VM from VMware' }
    dc = datacenter
    vm = getting_vm(dc, vm_name) || raise("ERROR: Could not destroy. VM `#{vm_name}` not found.")
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
    getting_vm(datacenter, vm_name)
  end

  def powerup_vm(vm)
    $logger.info "Powering On VM: #{vm_name}"
    vm.PowerOnVM_Task.wait_for_completion

    until (ip = vm.guest_ip) && !ip.include?(':') # Sometimes VMWare returns "internal" IPv6 address. Fix it.
      sleep 5
      $logger.info "#{vm_name}: waiting for VM to be up..."
    end

    $logger.info "#{vm_name}: got IP: #{ip}"

    ip
  end

  def create_vm
    dc        = datacenter
    vm_folder = get_vm_folder(dc)
    scheduler_opts = {
      vim: vim,
      dc: dc,
      vm_folder: vm_folder,
      computer_names: [opts[:computer_path]],
      datastore_paths: opts[:datastores],
    }
    scheduler = create_scheduler(scheduler_opts)

    # make_placement_decision call 'datacenter' method with can rase a RuntimeError. I need a recognize with type of errors was raised.
    # see: https://github.com/vmware/rbvmomi/blob/2e427817735e5df0aef1baa07bc95762e45a18bc/lib/rbvmomi/utils/admission_control.rb#L124
    begin
      scheduler.make_placement_decision
    rescue RuntimeError => e
      $logger.error { e.message }
      # Datastore not found
      ds_not_found = e.message.include?('datastore') && e.message.include?('not found')
      if ds_not_found
        raise e.message if opts[:datastores].size <= 1
        $logger.warn { 'Datastore not found. Retrying with new datastores.' }
        # grab ds from error
        bad_ds =  e.message.split(' ')[-3]
        opts[:datastores] = opts[:datastores] - [bad_ds]
        scheduler_opts[:datastore_paths] = opts[:datastores]
        scheduler = create_scheduler(scheduler_opts)
        retry
      end
    end

    datastore     = scheduler.datastore
    computer      = scheduler.pick_computer
    resource_pool = computer.resourcePool

    pc = vim.serviceContent.propertyCollector
    $logger.info { 'Choose computer from cluster' }
    hosts = computer.host
    hosts_props = pc.collectMultiple(
      hosts,
      'datastore', 'runtime.connectionState',
      'runtime.inMaintenanceMode', 'name'
    )

    # TODO: rework
    if opts[:computer]
      host = hosts.shuffle.find { |c| c.name == opts[:computer] }
    else
      host = hosts.shuffle.find do |x|
        host_props = hosts_props[x]
        is_connected = host_props['runtime.connectionState'] == 'connected'
        is_ds_accessible = host_props['datastore'].member?(datastore)
        is_connected && is_ds_accessible && !host_props['runtime.inMaintenanceMode']
      end
    end

    raise 'ERROR: No host in the cluster available to upload OVF to' unless host
    $logger.info { "Host: #{host.name}" }

    $logger.info { 'Mapping networks' }
    ovf = open(ovf_path, 'r') { |io| Nokogiri::XML(io.read) }
    ovf.remove_namespaces!

    networks = {}
    # Selcet networks from OVF
    ovf_networks = ovf.xpath('//NetworkSection/Network').map { |x| x['name'] }
    ovf_networks.each { |n| networks[n] = n } unless ovf_networks.blank?
    $logger.debug { "OVF networks=#{networks}" }

    network_mappings = {}
    if opts[:networks].blank?
      # Override ALL nwtworks to default network
      network = computer.network.find { |x| x.name == opts[:network] }
      network_mappings = Hash[ovf_networks.map { |x| [x, network] }]
    else
      # Mapping networks from user request
      custom_networks = Hash[*opts[:networks]] unless opts[:networks].blank?
      custom_networks.each_pair { |k,v| networks[k] = v } unless custom_networks.blank?

      $logger.debug { "Custom networks=#{custom_networks}" }

      networks.each_pair do |src, dst|
        $logger.info { "Network mapping: #{src} => #{dst}" }
        n = computer.network.find { |x| x.name == dst unless x.nil? }
        network_mappings[src] = n
      end
    end

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

  private

  def get_vm_folder(dc)
    $logger.debug { 'Get VM folder' }
    dc.vmFolder.traverse(opts[:vm_folder], VIM::Folder)
  end

  def create_scheduler(opts)
    $logger.debug { 'Create scheduler' }

    AdmissionControlledResourceScheduler.new(
      opts[:vim],
      datacenter: opts[:dc],
      computer_names: opts[:computer_names],
      vm_folder: opts[:vm_folder],
      rp_path: '/',
      datastore_paths: opts[:datastore_paths],
      max_vms_per_pod: nil, # No limits
      min_ds_free: nil, # No limits
    )
  end

  def getting_vm(datacenter, vm_name)
    vm_full_path = opts[:vm_folder] + '/' + vm_name
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
    $logger.error { e.backtrace.join("\n\t") }
    raise "ERROR: #{e.message}"
  end
end
