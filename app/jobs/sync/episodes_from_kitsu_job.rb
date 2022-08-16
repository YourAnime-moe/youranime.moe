# frozen_string_literal: true
module Sync
  class EpisodesFromKitsuJob < TrackableJob
    def perform(show)
      Shows::Sync.perform(sync_type: :episodes, show: show, requested_by: Users::Admin.system)
    end
  end
end
