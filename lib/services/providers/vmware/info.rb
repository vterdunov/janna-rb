require 'rbvmomi'
require 'yaml'
require_relative '../rbvmomi_wrapper'
require_relative './network'
require_relative './power'

# Provides some info about Virtual machine (power state, network interfaces)
class VMwareVMInfo
  attr_reader :vm_name, :vm_folder, :opts, :network_info, :power_info

  def initialize(opts)
    @vm_name      = opts[:vmname]
    @vm_folder    = opts[:vm_folder_path]
    @opts         = opts
    @network_info = VMwareNetwork.new(opts)
    @power_info   = VMwarePower.new(opts)
  end

  def info
    res = {}
    res[:network] = network
    res[:power] = power
    res
  end

  private

  def network
    network_info.info
  end

  def power
    power_info.info
  end
end
