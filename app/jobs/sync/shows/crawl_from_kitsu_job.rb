module Sync
  module Shows
    class CrawlFromKitsuJob < TrackableJob
      queue_as :sync

      def perform(range, staff:)
        ::Shows::Kitsu::Sync::Crawl.perform(years: range)
      end
    end
  end
end
