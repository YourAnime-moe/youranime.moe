# frozen_string_literal: true
module Sync
  module Shows
    class UpdateAiringScheduleJob < TrackableJob
      queue_as :sync

      def perform(show_ids)
        ::Shows::Update::AiringSchedule.perform(
          show_ids: show_ids,
        )
      end
    end
  end
end
