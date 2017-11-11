$default_vm_params = {
  host:           ENV['VSPHERE_ADDRESS'],
  port:           ENV['VSPHERE_PORT'],
  user:           ENV['VSPHERE_USERNAME'],
  password:       ENV['VSPHERE_PASSWORD'],
  datacenter:     ENV['VSPHERE_DC'],
  datastores:     ENV['VSPHERE_DATASTORES'],
  computer_path:  ENV['VSPHERE_CLUSTER'],
  network:        ENV['VSPHERE_NETWORK'],
  vm_folder:      ENV['VSPHERE_VM_FOLDER'],
  template_path:  ENV['VSPHERE_TEMPLATE_PATH'],
  path:           '/sdk',
  insecure:       true,
  ssl:            true,
  debug:          false
}
