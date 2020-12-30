# frozen_string_literal: true
module Sync
  module Shows
    class UpdateShowsJob < TrackableJob
      queue_as :sync

      def perform(show_ids, staff:)
        ::Shows::Update::ManyShows.perform(
          show_ids: show_ids,
        )
      end
    end
  end
end
