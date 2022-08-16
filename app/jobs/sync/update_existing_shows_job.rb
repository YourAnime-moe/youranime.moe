# frozen_string_literal: true
module Sync
  class UpdateExistingShowsJob < TrackableJob
    queue_as :sync

    def perform(force_update: false)
      ::Shows::Kitsu::Sync::UpdateExisting.perform(
        force_update: force_update,
      )
    end
  end
end
