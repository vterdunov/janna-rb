require 'rbvmomi'
require 'yaml'
require_relative '../rbvmomi_wrapper'


class VMwarePowerVM
  attr_reader :vm_name, :vm_folder, :opts

  def initialize(opts)
    @vm_name   = opts[:vmname]
    @vm_folder = opts[:vm_folder_path]
    @opts      = opts
  end

  # return [Hash] Hash of changed VM power state.
  def power_mgmt_vm
    dc = RbvmomiWrapper.datacenter(opts)
    unless vm = dc.find_vm("#{vm_folder}/#{vm_name}")
      res[:status] = 'error'
      res[:error] = 'VM not found'
      return res
    end

    $logger.info { "Start change the VM state to: #{opts[:state]}" }
    res = {}
    case opts[:state]
    when 'on'
      begin
        vm.PowerOnVM_Task.wait_for_completion
      rescue RbVmomi::Fault => e
        res[:status] = 'error'
        res[:error] = e
        return res
      end
    when 'off'
      begin
        vm.PowerOffVM_Task.wait_for_completion
      rescue RbVmomi::Fault => e
        res[:status] = 'error'
        res[:error] = e
        return res
      end
    when 'reset'
      begin
        vm.ResetVM_Task.wait_for_completion
      rescue RbVmomi::Fault => e
        res[:status] = 'error'
        res[:error] = e
        return res
      end
    when 'suspend'
      begin
        vm.SuspendVM_Task.wait_for_completion
      rescue RbVmomi::Fault => e
        res[:status] = 'error'
        res[:error] = e
        return res
      end
    else
      res[:status] = 'error'
      res[:error] = "ERROR: Invalid VM state. Values: 'on|off|reset|suspend'"
      return res
    end

    res[:status] = 'ok'
    res[:state] = opts[:state]
    res
  end
end
