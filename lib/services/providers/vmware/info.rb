require 'rbvmomi'
require 'yaml'
require_relative '../rbvmomi_wrapper'
require_relative './network'
require_relative './power'
require_relative './vm_config'

# Provides some info about Virtual machine (power state, network interfaces)
class VMwareVMInfo
  attr_reader :opts

  def initialize(opts)
    @opts = opts
  end

  def info
    res = {}
    res[:network] = network
    res[:power]   = power
    res = res.merge(vm_config)
    res
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    res[:ok] = false
    res[:error] = e.message
    res
  end

  private

  def network
    VMwareNetwork.new(opts).info
  end

  def power
    VMwarePower.new(opts).info
  end

  def vm_config
    VMwareVMConfig.new(opts).info
  end
end
