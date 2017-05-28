require 'rbvmomi'

module RbvmomiWrapper
  # Helper class
  class Helper
    def vim(opts)
    $logger.debug { 'Get Virtualized Infrastructure Manager' }
    RbVmomi::VIM.connect opts
    end

    def datacenter(opts)
      $logger.debug { 'Get Datacenter' }
      vim(opts).serviceInstance.find_datacenter(opts[:datacenter]) || abort('Datacenter not found')
    end

    def vm(opts)
      $logger.debug { 'Get Virtual Machine' }
      vm = datacenter(opts).find_vm("#{opts[:vm_folder_path]}/#{opts[:vmname]}")
      raise 'VM not found' if vm.blank?
      vm
    end
  end

  # Virtualized Infrastructure Manager
  #
  # @param [Hash] opts the options to get a VIM.
  # @option opts [String] :host
  # @option opts [String] :port
  # @option opts [String] :user
  # @option opts [String] :password
  # @option opts [String] :datacenter
  # @option opts [String] :insecure
  # @option opts [String] :ssl
  # @option opts [String] :debug
  #
  # return [RbVmomi::VIM]
  def self.vim(opts)
    Helper.new.vim(opts)
  end

  # VMware datacenter
  #
  # @param [Hash] opts the options to get a datacenter.
  # @option opts [String] :host
  # @option opts [String] :port
  # @option opts [String] :user
  # @option opts [String] :password
  # @option opts [String] :datacenter
  # @option opts [String] :insecure
  # @option opts [String] :ssl
  # @option opts [String] :debug
  #
  # return [Datacenter] VMware datastore
  def self.datacenter(opts)
    Helper.new.datacenter(opts)
  end

  # VMware Virtual Machine
  #
  # @param [Hash] opts the options to get a VM.
  # @option opts [String] :host
  # @option opts [String] :port
  # @option opts [String] :user
  # @option opts [String] :password
  # @option opts [String] :datacenter
  # @option opts [String] :insecure
  # @option opts [String] :ssl
  # @option opts [String] :debug
  # @option opts [String] :vm_folder_path
  # @option opts [String] :vmname
  #
  # return [VirtualMachine] VMware Virtual machine object
  def self.vm(opts)
    Helper.new.vm(opts)
  end
end
