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

  # return [Array] Array of VM IP addresss
  def vm_ip
    $logger.info { 'Get VM IP addresses' }
    addresses = {}
    dc = RbvmomiWrapper.datacenter(opts)
    vm = dc.find_vm("#{vm_folder}/#{vm_name}") || abort('VM not found')
    vm.guest.net.each_index do |i|
      puts addresses["nic#{i}"] = vm.guest.net[i].ipAddress
    end
    addresses
  end
end
