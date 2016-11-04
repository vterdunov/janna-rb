require_relative '../services/notifier'
require_relative '../services/downloader'
require_relative '../services/unpacker'
require_relative '../services/providers/vmware'

class VMwareWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(url, vmname)
    notify = Notifier.new
    notify.slack "Start deploy VM: `#{vmname}`"
    ip = do_work url, vmname
    notify.slack "VM `#{vmname}` has been deployed. IP: #{ip}"
  rescue RuntimeError => e
    $logger.error { e.message }
    $logger.error { e.backtrace.inspect }
    notify.slack e.message
  end

  def do_work(url, vmname)
    ova_path = Downloader.new(url).download
    tmp_dir  = Unpacker.new(ova_path).tar
    ovf_path = Dir["#{tmp_dir}/**/*.ovf"].first
    opts = {
      host: ENV['VSPHERE_ADDRESS'],
      port: 443,
      'no-ssl' => false,
      insecure: true,
      user: ENV['VSPHERE_USERNAME'],
      password: ENV['VSPHERE_PASSWORD'],
      path: '/sdk',
      debug: false,
      datacenter: ENV['VSPHERE_DC'],
      datastore: ENV['VSPHERE_DATASTORE'],
      template_name: vmname,
      template_path: ENV['VSPHERE_TEMPLATE_PATH'],
      computer_path: ENV['VSPHERE_COMPUTER_PATH'],
      network: ENV['VSPHERE_NETWORK'],
      vm_folder_path: ENV['VSPHERE_VM_FOLDER_PATH'],
      lease: 3,
      help: false,
      host_given: true,
      user_given: true,
      password_given: true,
      datacenter_given: true,
      datastore_given: true,
      network_given: true,
      computer_path_given: true,
      template_path_given: true,
      vm_folder_path_given: true,
      template_name_given: true,
      insecure_given: true,
      'no-ssl_given' => true,
      cookie: nil,
      ssl: true,
      ns: 'urn:vim25',
      rev: '6.0'
    }
    VMware.new(ovf_path, vmname, opts).deploy
  end
end
