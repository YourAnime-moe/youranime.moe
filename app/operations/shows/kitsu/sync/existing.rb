# frozen_string_literal: true
module Shows
  module Kitsu
    module Sync
      class Existing < ApplicationOperation
        def perform
          Rails.logger.info(
            "[Shows::Kitsu::Sync::Existing] synchrozing potentially #{show_ids.count} out-of-sync shows...",
          )
          ::Shows::Kitsu::Find.perform(kitsu_ids: show_ids, force_update: true)
        end

        private

        def show_ids
          @show_ids ||= Show.needing_update.where(reference_source: :kitsu).pluck(:reference_id)
        end
      end
    end
  end
end
