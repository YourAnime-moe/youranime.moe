module Sync
  class EpisodesFromKitsuJob < TrackableJob
    def perform(show, staff:)
      Shows::Sync.perform(sync_type: :episodes, show: show, requested_by: staff)
    end
  end
end
