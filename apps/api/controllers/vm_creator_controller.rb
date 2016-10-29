class VmCreatorController < Application
  post '/' do
    ova_url = params[:address]
    vmname  = params[:vmname]
    WMwareWorker.perform_async ova_url, vmname
  end
end
