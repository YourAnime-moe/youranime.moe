# frozen_string_literal: true
module Sync
  class ShowFromKitsuJob < TrackableJob
    queue_as :sync

    def perform(show, staff:)
      ::Shows::Sync.perform(sync_type: :show, show: show, requested_by: staff)
    end
  end
end
