# frozen_string_literal: true
module Sync
  module Shows
    class CrawlFromKitsuJob < TrackableJob
      queue_as :sync

      def perform(from, til, staff:)
        ::Shows::Kitsu::Sync::Crawl.perform(years: (from..til))
      end
    end
  end
end
