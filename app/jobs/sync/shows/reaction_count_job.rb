# frozen_string_literal: true
module Sync
  module Shows
    class ReactionCountJob < TrackableJob
      queue_as :sync

      def perform(show)
        show.update!(
          likes_count: show.likes.count,
          dislikes_count: show.dislikes.count,
        )
      end
    end
  end
end
