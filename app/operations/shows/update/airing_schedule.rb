# frozen_string_literal: true
module Shows
  module Update
    class AiringSchedule < ApplicationOperation
      property! :show_ids, accepts: Array, converts: :to_a

      def perform
        Show.where(id: show_ids).each do |show|
          Shows::Anilist::NextAiringEpisode.perform(
            slug: show.slug,
            force: true,
          )
        rescue => e
          Rails.logger.error("[Shows::Update::AiringSchedule] failure: #{e}")
        end
      end
    end
  end
end
