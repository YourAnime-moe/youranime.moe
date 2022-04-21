# frozen_string_literal: true
module Sync
  class ShowsFromKitsuJob < TrackableJob
    queue_as :sync

    def perform(season, staff:)
      message = "[Sync::ShowsFromtKitsuJob] Syncing #{season} season..."
      Rails.logger.info(message)

      processed_shows = ::Shows::Kitsu::Sync::Airing.perform(season: season)
      updated_shows = ::Shows::Kitsu::Sync::Existing.perform

      processed_shows_count = processed_shows.count + updated_shows.count

      message = "[Sync::ShowsFromtKitsuJob] Processed #{processed_shows_count} show(s)!"
      Rails.logger.info(message)
    end
  end
end
