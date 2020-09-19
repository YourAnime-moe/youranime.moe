module Sync
  module Shows
    class CrawlFromKitsuJob < TrackableJob
      queue_as :sync

      def perform(staff:)
        ::Shows::Sync.perform(sync_type: :crawl, requested_by: staff)
      end
    end
  end
end
