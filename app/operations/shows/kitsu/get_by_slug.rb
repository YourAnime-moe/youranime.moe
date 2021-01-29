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
        show = Show.find_slug(slug, reference_source: :kitsu)
        return show.reference_id if show.present?

        scrap_for_kitsu_id_from_slug
      end

      def scrap_for_kitsu_id_from_slug
        html_data = Nokogiri::HTML(RestClient.get(kitsu_html_url))
        nodes = html_data.css('.cover-photo')

      rescue RestClient::Exception
        nil
      end

      def kitsu_html_url
        "https://kitsu.io/anime/#{slug}"
      end
    end
  end
end
