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

    @template_folder_path = opts[:template_path]
    @template_name = @opts[:template_name]
  end

  def start
    # config
    vim = VIM.connect @opts
    dc = vim.serviceInstance.find_datacenter(@opts[:datacenter])
    root_vm_folder = dc.vmFolder

    vm_folder = root_vm_folder.traverse(@opts[:vm_folder_path], VIM::Folder)
    template_folder = root_vm_folder.traverse!(@template_folder_path, VIM::Folder)

    scheduler = AdmissionControlledResourceScheduler.new(
      vim,
      datacenter: dc,
      computer_names: [@opts[:computer_path]],
      vm_folder: vm_folder,
      rp_path: '/',
      datastore_paths: [@opts[:datastore]],
      max_vms_per_pod: nil, # No limits
      min_ds_free: nil, # No limits
    )
    scheduler.make_placement_decision

    datastore = scheduler.datastore
    computer = scheduler.pick_computer
    network = computer.network.find { |x| x.name == @opts[:network] }

    @lease_tool = LeaseTool.new
    @lease = @opts[:lease] * 24 * 60 * 60

    @deployer = CachedOvfDeployer.new(
      vim, network, computer, template_folder, vm_folder, datastore
    )
    template = @deployer.lookup_template @template_name

    # ----------------------------------------
    template = deploy_template template

    vm = clone_vm_from_template template

    ip = powerup_vm vm
    ip
  end

  private

  def deploy_template(template)
    unless template
      puts 'Uploading/Preparing OVF template ...'

      template = @deployer.upload_ovf_as_template(
        @ovf_path, @template_name,
        run_without_interruptions: true,
        config: @lease_tool.set_lease_in_vm_config({}, @lease)
      )
    end
    template
  end

  def clone_vm_from_template(template)
    puts 'Cloning template ...'
    config = {
      numCPUs: @opts[:cpus],
      memoryMB: @opts[:memory]
    }
    config = @lease_tool.set_lease_in_vm_config(config, @lease)
    @deployer.linked_clone template, @vm_name, config
  rescue RbVmomi::VIM::DuplicateName => e
    puts e.message
    puts e.backtrace.inspect
    send_slack_notify "ERROR: VM `#{@vm_name}` already exist!"
    raise
  end

  def powerup_vm(vm)
    puts 'Powering On VM ...'
    vm.PowerOnVM_Task.wait_for_completion

    puts 'Waiting for VM to be up ...'
    until (ip = vm.guest_ip)
      sleep 5
    end

    puts "VM got IP: #{ip}"
    puts 'Done'

    ip
  end

  # TODO: move to helper method
  def send_slack_notify(msg)
    notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'],
                                   channel: ENV['SLACK_CHANNEL'],
                                   username: ENV['SLACK_USERNAME'],
                                   icon_url: 'http://vignette1.wikia.nocookie.net/leagueoflegends/images/b/b0/JannaSquare_old2.png'

    notifier.ping msg
  end
end
