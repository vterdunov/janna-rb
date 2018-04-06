require 'fileutils'
require_relative '../abstract_worker'
require_relative '../../services/downloader'
require_relative '../../services/unpacker'
require_relative '../../services/providers/vmware/vmware'

class VMwareDeployOVA < AbstractWorker
  def do_work(vim, datacenter, params)
    $logger.info { "Start deploy VM from OVA to VMware, vmname: #{params[:vmname]}" }
    store stage: 'strating'
    raise "ERROR: VM `#{params[:vmname]}` already exists." if VMware.new(vim, datacenter, params).vm_exist?
    store stage: 'getting OVA'
    ova_path = Downloader.new(params[:ova_url]).download
    tmp_dir  = Unpacker.new(ova_path).tar
    params[:ovf_path] = Dir["#{tmp_dir}/**/*.ovf"].first
    raise "ERROR: Cannot get OVF file for `#{params[:vmname]}`" unless params[:ovf_path]
    store stage: 'creating vm'
    vm = VMware.new(vim, datacenter, params).create_vm
    store stage: 'getting ip'
    ip = VMware.new(vim, datacenter, params).powerup_vm(vm)
    store stage: 'deployed'
    $slacker.notify("VM `#{params[:vmname]}` has been deployed. IP: #{ip}",
                    to: params[:message_to],
                    level: 'good')
  ensure
    FileUtils.remove_dir(tmp_dir)
  end
end
