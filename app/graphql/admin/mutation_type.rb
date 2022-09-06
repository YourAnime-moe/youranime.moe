# frozen_string_literal: true
module Admin
  class MutationType < ::Types::BaseObject
    field :sync_show_now, Admin::Types::ShowRecord, null: true do
      argument :slug, String, required: true
    end
    def sync_show_now(slug:)
      show = Show.find_by(slug: slug)
      Sync::ShowFromKitsuJob.perform_now(show)
      Shows::Anilist::NextAiringEpisode.perform(slug: show.slug, update: true)
      Shows::Anilist::Streamers.perform(
        show: show,
        anilist_id: show.anilist_id,
        persist: true,
      ) if show.anilist_id.present?

      show.reload
      show
    end

    field :run_task, Admin::Types::JobEvent, null: true do
      argument :task, String, required: true
    end
    def run_task(task:)
      Admin::InvokeTask.perform(task: task)
    end

    field :cancel_job, GraphQL::Types::Boolean, null: true do
      argument :job_id, String, required: true
    end
    def cancel_job(job_id:)
      Admin::CancelJob.perform(job_id: job_id, user: context[:current_user])
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end
