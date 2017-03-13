$default_vm_params = {
  host:           ENV['VSPHERE_ADDRESS'],
  port:           ENV['VSPHERE_PORT'],
  user:           ENV['VSPHERE_USERNAME'],
  password:       ENV['VSPHERE_PASSWORD'],
  datacenter:     ENV['VSPHERE_DC'],
  datastore:      ENV['VSPHERE_DATASTORE'],
  computer_path:  ENV['VSPHERE_CLUSTER'],
  network:        ENV['VSPHERE_NETWORK'],
  vm_folder_path: ENV['VSPHERE_VM_FOLDER'],
  template_path:  ENV['VSPHERE_TEMPLATE_PATH'],
  path:           '/sdk',
  insecure:       true,
  ssl:            true,
  debug:          false
}
