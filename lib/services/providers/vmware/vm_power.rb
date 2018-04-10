require 'rbvmomi'
require 'yaml'
require 'date'
require_relative '../rbvmomi_wrapper'

# Provides VM power management
class VMwareVMPower
  attr_reader :opts, :vm

  def initialize(opts)
    @opts = opts
  end

  # return [Hash] Hash of VM power information.
  def info
    vm_runtime = vm.summary.runtime
    {
      state: vm_runtime.powerState,
      boot_time: vm_runtime.bootTime,
      consolidation_needed: vm_runtime.consolidationNeeded
    }
  end

  # return [Hash] Hash of changed VM power state.
  def power_mgmt_vm
    res = {}

    $logger.info { "Start change the VM state to: #{opts[:state]}" }
    case opts[:state]
    when 'on'
      begin
        vm.PowerOnVM_Task.wait_for_completion
      rescue RbVmomi::Fault => e
        res[:ok] = false
        res[:error] = e
        return res
      end
    when 'off'
      begin
        vm.PowerOffVM_Task.wait_for_completion
      rescue RbVmomi::Fault => e
        res[:ok] = false
        res[:error] = e
        return res
      end
    when 'reset'
      begin
        vm.ResetVM_Task.wait_for_completion
      rescue RbVmomi::Fault => e
        res[:ok] = false
        res[:error] = e
        return res
      end
    when 'suspend'
      begin
        vm.SuspendVM_Task.wait_for_completion
      rescue RbVmomi::Fault => e
        res[:ok] = false
        res[:error] = e
        return res
      end
    else
      res[:ok] = false
      res[:error] = "ERROR: Invalid VM state. Values: 'on|off|reset|suspend'"
      return res
    end

    res[:ok] = true
    res[:state] = opts[:state]
    res
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.join("\n\t") }
    res[:ok] = false
    res[:error] = e.message
    res
  end

  private

  def vm
    RbvmomiWrapper.vm(opts)
  end
end
