module Sync
  class ShowsFromKitsuJob < TrackableJob
    def perform(staff:)
      processed_shows = Shows::Sync.perform(sync_type: :airing, requested_by: staff)
      Rails.logger.info("[Sync::ShowsFromtKitsuJob] Processed #{processed_shows.count} show(s)!")
    end
  end
end
