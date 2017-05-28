require 'rbvmomi'
require 'yaml'
require_relative '../rbvmomi_wrapper'

# Provides VM network information
class VMwareNetwork
  attr_reader :opts, :vm

  def initialize(opts)
    @opts = opts
  end

  # return [Hash] Hash of VM network information:
  #   IP and MAC adresses, state of connections, VMware network name, etc
  def info
    $logger.info { 'Get VM network information' }
    res = {}

    vm_networks = vm.guest.net
    vm_networks.each_index do |i|
      res["network_adapter#{i + 1}"] = {
        ip_address: vm_networks[i].ipAddress,
        network: vm_networks[i].network,
        connected: vm_networks[i].connected,
        device_config_id: vm_networks[i].deviceConfigId,
        mac_address: vm_networks[i].macAddress
      }
    end

    res
  end

  private

  def vm
    RbvmomiWrapper.vm(opts)
  end
end
