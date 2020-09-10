module Sync
  class EpisodesFromKitsuJob < ApplicationJob
    def perform(show, by_user:)
      Shows::Sync.perform(sync_type: :episodes, show: show, requested_by: by_user)
    end
  end
end
