require_relative '../abstract_worker'
require_relative '../../services/providers/vmware/vmware'

class VMwareDeployTemplate < AbstractWorker
  def do_work(vim, datacenter, params)
    $logger.info { "Start deploy VM from Template to VMware, vmname: #{params[:vmname]}" }
    store stage: 'strating'
    $slacker.notify("Start deploy VM: `#{params[:vmname]}` from template: `#{params[:template_name]}`",
                    to: params[:message_to])
    raise "ERROR: VM `#{params[:vmname]}` already exists." if VMware.new(vim, datacenter, params).vm_exist?
    store stage: 'creating vm'
    vm = VMware.new(vim, datacenter, params).deploy_from_template
    store stage: 'getting ip'
    ip = VMware.new(vim, datacenter, params).powerup_vm(vm)
    store stage: 'deployed'
    $slacker.notify("VM `#{params[:vmname]}` has been deployed. IP: #{ip}",
                    to: params[:message_to], level: 'good')
  end
end
