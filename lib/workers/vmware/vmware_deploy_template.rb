require_relative '../abstract_worker'
require_relative '../services/providers/vmware'

class VMwareDeployTemplate < AbstractWorker
  def do_work(vim, datacenter, params)
    $slacker.notify("Start deploy VM: `#{params[:vmname]}` from template: `#{params[:template_name]}`")
    raise "ERROR: VM `#{params[:vmname]}` already exists." if VMware.new(vim, datacenter, params).vm_exist?
    ip = VMware.new(vim, datacenter, params).deploy_from_template
    $slacker.notify("VM `#{params[:vmname]}` has been deployed. IP: #{ip}", nil, 'good')
  end
end
