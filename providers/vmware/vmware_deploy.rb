require 'rbvmomi'
require 'rbvmomi/utils/deploy'
require 'rbvmomi/utils/admission_control'
require 'rbvmomi/utils/leases'
require 'yaml'

class VMwareDeploy
  VIM = RbVmomi::VIM

  def initialize(ovf_path, vm_name, opts = {})
    @ovf_path = ovf_path
    @vm_name = vm_name
    @opts = opts
  end

  def start
    # puts @ovf_path
    # puts @vm_name
    # puts @opts

    vim = VIM.connect @opts
    dc = vim.serviceInstance.find_datacenter(@opts[:datacenter])
    template_folder_path = @opts[:template_path]
    template_name = @opts[:template_name]
    root_vm_folder = dc.vmFolder
    vm_folder = root_vm_folder

    if @opts[:vm_folder_path]
      vm_folder = root_vm_folder.traverse(@opts[:vm_folder_path], VIM::Folder)
    end
    template_folder = root_vm_folder.traverse!(template_folder_path, VIM::Folder)

    scheduler = AdmissionControlledResourceScheduler.new(
      vim,
      :datacenter => dc,
      :computer_names => [@opts[:computer_path]],
      :vm_folder => vm_folder,
      :rp_path => '/',
      :datastore_paths => [@opts[:datastore]],
      :max_vms_per_pod => nil, # No limits
      :min_ds_free => nil, # No limits
    )
    scheduler.make_placement_decision

    datastore = scheduler.datastore
    computer = scheduler.pick_computer
    # XXX: Do this properly
    if @opts[:network]
      network = computer.network.find{|x| x.name == @opts[:network]}
    else
      network = computer.network[0]
    end

    lease_tool = LeaseTool.new
    lease = @opts[:lease] * 24 * 60 * 60
    deployer = CachedOvfDeployer.new(
      vim, network, computer, template_folder, vm_folder, datastore
    )
    template = deployer.lookup_template template_name

    if !template
      puts "#{Time.now}: Uploading/Preparing OVF template ..."

      template = deployer.upload_ovf_as_template(
        @ovf_path, template_name,
        :run_without_interruptions => true,
        :config => lease_tool.set_lease_in_vm_config({}, lease)
      )
    end

    puts "#{Time.now}: Cloning template ..."
    config = {
      :numCPUs => @opts[:cpus],
      :memoryMB => @opts[:memory],
    }
    config = lease_tool.set_lease_in_vm_config(config, lease)
    vm = deployer.linked_clone template, @vm_name, config

    puts "#{Time.now}: Powering On VM ..."
    # XXX: Add a retrying version?
    vm.PowerOnVM_Task.wait_for_completion

    puts "#{Time.now}: Waiting for VM to be up ..."
    ip = nil
    while !(ip = vm.guest_ip)
      sleep 5
    end

    puts "#{Time.now}: VM got IP: #{ip}"

    puts "#{Time.now}: Done"
  end
end
