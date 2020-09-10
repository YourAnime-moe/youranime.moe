module Sync
  class ShowsFromKitsuJob < ApplicationJob
    def perform(by_user:)
      processed_shows = Shows::Sync.perform(sync_type: :airing, requested_by: by_user)
      Rails.logger.info("[Sync::ShowsFromtKitsuJob] Processed #{processed_shows.count} show(s)!")
    end
  end
end
