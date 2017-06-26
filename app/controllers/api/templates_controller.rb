class TemplatesController < ApplicationController
  # Create VM from Template
  #
  # @param opts Request body.
  # @option opts [String] :provider_type +Required+ Hypervisor provider type. Possible values: `vmware`
  # @option opts [String] :vmname        +Required+ Virtual Machine name
  # @option opts [String] :template_name +Required+ Template name
  # @option opts [String] :template_path +Optional+ Path to Templates folder
  # @option opts [String] :network  *    +Optional+ Network name
  # @option opts [String] :datacenter    +Optional+ Datacenter name
  # @option opts [String] :datastore     +Optional+ Datastore name
  # @option opts [String] :cluster       +Optional+ Cluster name
  # @option opts [String] :vm_folder     +Optional+ Folder name where VM will be created
  # @option opts [String] :message_to    +Optional+ Usernaame or Channel to send messages
  #
  # @return [json] 202 Accepted. Deploy VM in progress.
  post '/v1/template' do
    content_type :json
    job_id = rest_router.perform_async(vm_params)
    $slacker.notify("Start deploy VM: `#{vm_params[:vmname]}` from template: `#{vm_params[:template_name]}`",
                    to: vm_params[:message_to],
                    footer: "JID: #{job_id}")
    status 202
    { ok: true, job_id: job_id }.to_json
  end
end
