require_relative '../abstract_worker'
require_relative '../../services/providers/vmware/vmware'

class VMwareDestroyVM < AbstractWorker
  def do_work(vim, datacenter, params)
    $slacker.notify("Start destroy VM: `#{params[:vmname]}`.", to: params[:message_to])
    VMware.new(vim, datacenter, params).destroy_vm
    $slacker.notify("VM `#{params[:vmname]}` has been destroyed.",
                    to: params[:message_to],
                    level: 'good')
  end
end
