require 'rbvmomi'
require 'yaml'
require_relative '../rbvmomi_wrapper'

# Provides miscellaneous VM information
class VMwareVMConfig
  attr_reader :opts, :vm

  def initialize(opts)
    @opts = opts
  end

  # return [Hash] Hash of miscellaneous VM information.
  def info
    vm_config = vm.config
    {
      name: vm_config.name,
      uuid: vm_config.uuid,
      instance_uuid: vm_config.instanceUuid
    }
  end

  private

  def vm
    RbvmomiWrapper.vm(opts)
  end
end
