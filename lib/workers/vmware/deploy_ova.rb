require_relative '../abstract_worker'
require_relative '../../services/downloader'
require_relative '../../services/unpacker'
require_relative '../../services/providers/vmware/vmware'

class VMwareDeployOVA < AbstractWorker
  def do_work(vim, datacenter, params)
    store stage: 'strating'
    $logger.info { "Start deploy VM from OVA to VMware, vmname: #{params[:vmname]}" }
    # TODO: Create single vmware obj. And reuse into check exists, creating vm and getting vm. Should pass ova_path to create_vm method
    if VMware.new(vim, datacenter, params).vm_exist?
      store stage: 'canceled'
      raise "ERROR: VM `#{params[:vmname]}` already exists."
    end

    store stage: 'getting OVA'
    ova_path = Downloader.new(params[:ova_url]).download
    unpacked_dir = Unpacker.new().untar(ova_path)
    params[:ovf_path] = Dir["#{unpacked_dir}/**/*.ovf"].first
    raise "Cannot get OVF file for `#{params[:vmname]}`" unless params[:ovf_path]

    store stage: 'creating vm'
    # TODO: Get ovf_path from 'create_vm' arguments, not from params
    vm = VMware.new(vim, datacenter, params).create_vm

    store stage: 'getting ip'
    ip = VMware.new(vim, datacenter, params).powerup_vm(vm)

    store stage: 'deployed'
    store ip: ip
    $slacker.notify("VM `#{params[:vmname]}` has been deployed. IP: #{ip}",
                    to: params[:message_to],
                    level: 'good')
  ensure
    FileUtils.remove_dir(unpacked_dir) unless unpacked_dir.blank?
    FileUtils.remove_dir(File.dirname(ova_path)) unless ova_path.blank?
  end
end
