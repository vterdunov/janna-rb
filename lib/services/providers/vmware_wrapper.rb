require 'rbvmomi'

module VMwareWrapper
  # Virtualized Infrastructure Manager
  #
  # @param [Hash] opts the options to create a datacenter.
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
    $logger.debug { 'Get VIM' }
    RbVmomi::VIM.connect opts
  end

  # VMware datacenter
  #
  # @param [Hash] opts the options to create a datacenter.
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
    $logger.debug { 'Get datacenter' }
    # TODO: Can i reuse `vim` method?
    vim = RbVmomi::VIM.connect opts
    vim.serviceInstance.find_datacenter(opts[:datacenter]) || abort('datacenter not found')
  end
end
