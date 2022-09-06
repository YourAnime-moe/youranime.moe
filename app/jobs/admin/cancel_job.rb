module Admin
  class CancelJob < ApplicationOperation
    property! :job_id, accepts: String
    property! :user, accepts: Users::Admin
    property :canceled_reason, accepts: String

    def execute
      job.mark_as_canceled!(user, canceled_reason: canceled_reason)
    end

    private

    def job
      @job ||= JobEvent.find(job_id)
    end
  end
end
