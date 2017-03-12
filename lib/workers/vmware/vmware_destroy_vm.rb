require_relative '../abstract_worker'
require_relative '../../services/providers/vmware'

class VMwareDestroyVM < AbstractWorker
  def do_work(vim, datacenter, params)
    $slacker.notify("Start destroy VM: `#{params[:vmname]}`.")
    VMware.new(params).destroy_vm
    $slacker.notify("VM `#{params[:vmname]}` has been destroyed.", nil, 'good')
  end
end
