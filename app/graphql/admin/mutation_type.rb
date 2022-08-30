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

      show.reload
      show
    end
  end
end