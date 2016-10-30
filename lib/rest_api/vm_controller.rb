require_relative '../workers/vmware_worker'

class ApplicationController
  post '/vm' do
    ova_url = params[:address]
    vmname  = params[:vmname]

    VMwareWorker.perform_async ova_url, vmname
    status 202
  end
end
