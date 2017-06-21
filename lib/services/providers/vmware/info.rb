require 'rbvmomi'
require 'yaml'
require_relative '../rbvmomi_wrapper'
require_relative './vm_network'
require_relative './vm_power'
require_relative './vm_config'

# Provides some info about Virtual machine (power state, network interfaces)
class VMwareVMInfo
  attr_reader :opts

  def initialize(opts)
    @opts = opts
  end

  def info
    $logger.info { 'Get VM info' }
    res = {}
    network = vm_network
    power   = vm_power
    config  = vm_config

    res[:network] = network unless network.blank?
    res[:power]   = power unless power.blank?
    res = res.merge(config) unless config.blank?
    res
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    res[:ok] = false
    res[:error] = e.message
    res
  end

  private

  def vm_network
    VMwareVMNetwork.new(opts).info
  end

  def vm_power
    VMwareVMPower.new(opts).info
  end

  def vm_config
    VMwareVMConfig.new(opts).info
  end
end
