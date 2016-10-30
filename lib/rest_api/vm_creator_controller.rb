require_relative '../workers/vmware_worker'

class VmCreatorController < ApplicationController
  post '/' do
    ova_url = params[:address]
    vmname  = params[:vmname]

    VMwareWorker.perform_async ova_url, vmname
    status 202
  end
end
