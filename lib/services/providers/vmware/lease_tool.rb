require 'rbvmomi'
require 'rbvmomi/utils/leases'
require 'yaml'
require_relative '../rbvmomi_wrapper'

class Lease
  attr_reader :opts

  VIM = RbVmomi::VIM

  def initialize(opts)
    @opts = opts
  end

  # @return [Array<String>] Names of expired VMs
  def expired
    vim = RbvmomiWrapper.vim(opts)
    dc = RbvmomiWrapper.datacenter(opts)
    root_vm_folder = dc.vmFolder
    vm_folder = root_vm_folder.traverse(opts[:vm_folder], VIM::Folder)

    lease_tool = LeaseTool.new
    vms_props_list = (['runtime.powerState'] + lease_tool.vms_props_list).uniq
    inventory = vm_folder.inventory_flat('VirtualMachine' => vms_props_list)
    inventory = inventory.select { |obj, _| obj.is_a?(VIM::VirtualMachine) }
    puts 'kkkkkkkkk'
    vms = filter_expired_vms(inventory)
    # vms.each do |vm, time_to_expiration|
    #   puts "VM '#{inventory[vm]['name']}' is expired"
    # end
  end

  private

  def filter_expired_vms(vms, opts = {})
    time_delta = opts[:time_delta] || 0
    time = current_time + time_delta

    vms.each do |vm, props|
      next unless annotation = props['config.annotation']
      puts annotation.class
      begin
        note = YAML.load annotation
      rescue
        next
      end
      puts "#{vm.name}: #{note}"
    end
    puts '+'*500
    # out = vms.map do |vm|
    #   props = vmprops[vm]
    #   next unless annotation = props['config.annotation']
    #   note = YAML.load annotation
    #   next unless note.is_a?(Hash) && lease = note['lease']
    #   next unless time > lease
    #   time_to_expiration = ((lease - time) + time_delta)
    #   [vm, time_to_expiration]
    # end.compact
    #   out = Hash[out]
    #   out
    # end
  end

  def current_time
    Time.now
  end

  # @param [String] annotation
  # @return [Hash] Hash with lease date
  def parse_annotation

  end
end
