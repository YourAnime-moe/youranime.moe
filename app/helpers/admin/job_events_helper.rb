module Admin
  module JobEventsHelper
    def job_event_status_tag(job_event)
      colour = if job_event.running?
        'warning'
      elsif job_event.complete?
        'success'
      elsif job_event.failed?
        'danger'
      else
        'light'
      end

      value_tag(job_event.status, colour: colour)
    end
  end
end
