require_relative '../abstract_worker'
require_relative '../../services/downloader'
require_relative '../../services/unpacker'
require_relative '../../services/providers/vmware'

class VMwareDeployOVA < AbstractWorker
  def do_work(vim, datacenter, params)
    $slaker.notify("Start deploy VM: `#{params[:vmname]}`", params[:message_to])
    raise "ERROR: VM `#{params[:vmname]}` already exists." if VMware.new(vim, datacenter, params).vm_exist?
    ova_path = Downloader.new(params[:ova_url]).download
    tmp_dir  = Unpacker.new(ova_path).tar
    params[:ovf_path] = Dir["#{tmp_dir}/**/*.ovf"].first
    raise "ERROR: Cannot get OVF file for `#{vmname}`" unless params[:ovf_path]
    ip = VMware.new(vim, datacenter, params).deploy_ova
    $slaker.notify("VM `#{params[:vmname]}` has been deployed. IP: #{ip}", params[:message_to], 'good')
  end
end
