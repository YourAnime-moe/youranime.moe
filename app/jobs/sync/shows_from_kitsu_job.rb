# frozen_string_literal: true
module Sync
  class ShowsFromKitsuJob < TrackableJob
    queue_as :sync

    def perform(season, staff:)
      Rails.logger.info("[Sync::ShowsFromtKitsuJob] Syncing #{season} season...")
      processed_shows = ::Shows::Kitsu::Sync::Airing.perform(season: season)
      Rails.logger.info("[Sync::ShowsFromtKitsuJob] Processed #{processed_shows.count} show(s)!")
    end
  end
end
