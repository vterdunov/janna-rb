require 'rbvmomi'
require 'rbvmomi/utils/deploy'
require 'rbvmomi/utils/admission_control'
require 'yaml'
require_relative '../vmware_wrapper'

class VMwareVM
  attr_reader :vm_name, :opts

  def initialize(opts)
    @vm_name = opts[:vmname]
    @opts    = opts
  end

  # return [Array] Array of VM IP addresss
  def vm_ip
    $logger.info { 'Get VM IP addresses' }
    addresses = []
    dc = VMwareWrapper.datacenter(opts)
    vm = dc.find_vm("#{opts[:vm_folder_path]}/#{vm_name}") || abort('VM not found')
    vm.guest.net.each do |nic|
      addresses << nic.ipAddress
    end
    addresses
  end
end
