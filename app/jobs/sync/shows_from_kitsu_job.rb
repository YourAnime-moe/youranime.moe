# frozen_string_literal: true
module Sync
  class ShowsFromKitsuJob < TrackableJob
    queue_as :sync

    def perform(season, staff:)
      Rails.logger.info("[Sync::ShowsFromtKitsuJob] Syncing #{season} season...")

      processed_shows = ::Shows::Kitsu::Sync::Airing.perform(season: season)
      updated_shows = ::Shows::Kitsu::Sync::Existing.perform

      processed_shows_count = processed_shows.count + updated_shows.count

      Rails.logger.info("[Sync::ShowsFromtKitsuJob] Processed #{processed_shows_count} show(s)!")
    end
  end
end
