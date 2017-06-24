class JobsController < ApplicationController
  # Get list of background jobs
  #
  # @param opts Request body.
  # @option opts [String] :provider_type +Required+ Hypervisor provider type. Possible values: `vmware`
  # @option opts [String] :message_to    +Optional+ Usernaame or Channel to send messages
  #
  # @return [json] List of background jobs.
  get '/v1/jobs' do
    content_type :json
    rest_router.new(vm_params).job_list.to_json
  end

  # Get background job status
  #
  # @param opts Request body.
  # @option opts [String] :provider_type +Required+ Hypervisor provider type. Possible values: `vmware`
  # @option opts [String] :job_id        +Required+ Background job ID.
  # @option opts [String] :message_to    +Optional+ Usernaame or Channel to send messages
  #
  # @return [json] Background job by ID.
  get '/v1/jobs/:id' do
    content_type :json
    job = JobsStatus.new(vm_params)
    job.job_status(params[:id]).to_json
  end
end
