require 'rbvmomi'
require 'yaml'
require_relative '../rbvmomi_wrapper'

# Provides VM network information
class VMwareNetwork
  attr_reader :vm_name, :vm_folder, :opts

  def initialize(opts)
    @vm_name   = opts[:vmname]
    @vm_folder = opts[:vm_folder_path]
    @opts      = opts
  end

  # return [Hash] Hash of VM network information:
  #   IP and MAC adresses, state of connections, VMware network name, etc
  def info
    $logger.info { 'Get VM network information' }
    res = {}

    unless vm
      res[:ok] = false
      res[:error] = 'VM not found'
      return res
    end

    vm.guest.net.each_index do |i|
      res["network_adapter#{i + 1}"] = {
        ip_address: vm.guest.net[i].ipAddress,
        network: vm.guest.net[i].network,
        connected: vm.guest.net[i].connected,
        device_config_id: vm.guest.net[i].deviceConfigId,
        mac_address: vm.guest.net[i].macAddress
      }
    end
    res
  end

  private

  def vm
    dc.find_vm("#{vm_folder}/#{vm_name}")
  end

  def dc
    RbvmomiWrapper.datacenter(opts)
  end
end
