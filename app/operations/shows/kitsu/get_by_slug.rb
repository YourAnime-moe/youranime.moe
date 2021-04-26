# frozen_string_literal: true
module Shows
  module Kitsu
    class GetBySlug < ApplicationOperation
      property! :slug # , converts: -> (slug) { slug.to_s.strip.downcase }
      property :force_update, accepts: [true, false], default: false

      def perform
        kitsu_id = kitsu_id_for_slug
        return unless kitsu_id.present?

        Shows::Kitsu::Get.perform(
          kitsu_id: kitsu_id,
          force_update: force_update,
        )
      end

      private

      def kitsu_id_for_slug
        Show.find_by(slug: slug, reference_source: :kitsu)&.reference_id
      end
    end
  end
end
