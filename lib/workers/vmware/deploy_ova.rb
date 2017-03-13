require_relative '../abstract_worker'
require_relative '../../services/downloader'
require_relative '../../services/unpacker'
require_relative '../../services/providers/vmware/vmware'

class VMwareDeployOVA < AbstractWorker
  def do_work(vim, datacenter, params)
    puts params
    $slacker.notify("Start deploy VM: `#{params[:vmname]}`", to: params[:message_to])
    raise "ERROR: VM `#{params[:vmname]}` already exists." if VMware.new(vim, datacenter, params).vm_exist?
    ova_path = Downloader.new(params[:ova_url]).download
    tmp_dir  = Unpacker.new(ova_path).tar
    params[:ovf_path] = Dir["#{tmp_dir}/**/*.ovf"].first
    raise "ERROR: Cannot get OVF file for `#{params[:vmname]}`" unless params[:ovf_path]
    ip = VMware.new(vim, datacenter, params).deploy_ova
    $slacker.notify("VM `#{params[:vmname]}` has been deployed. IP: #{ip}",
                    to: params[:message_to],
                    level: 'good')
  end
end
