require 'rbvmomi'
require 'yaml'
require_relative '../rbvmomi_wrapper'

class VMwareIP
  attr_reader :vm_name, :vm_folder, :opts

  def initialize(opts)
    @vm_name   = opts[:vmname]
    @vm_folder = opts[:vm_folder_path]
    @opts      = opts
  end

  # return [Hash] Hash of VM NIC and IP addresss.
  def vm_ip
    $logger.info { 'Get VM IP addresses' }
    res = {}
    dc = RbvmomiWrapper.datacenter(opts)
    unless vm = dc.find_vm("#{vm_folder}/#{vm_name}")
      res[:status] = 'error'
      res[:error] = 'VM not found'
      return res
    end
    vm.guest.net.each_index do |i|
      puts res["nic#{i}"] = vm.guest.net[i].ipAddress
    end
    res
  end
end
