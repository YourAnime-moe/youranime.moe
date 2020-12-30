# frozen_string_literal: true
module Shows
  module Kitsu
    class Get < ::Kitsu::ApplicationOperation
      property! :kitsu_id
      property :force_update, accepts: [true, false], default: false

      class NotFound < StandardError; end

      class NSFWError < NotFound; end

      def perform
        show = Show.find_kitsu(kitsu_id)
        show = if show.present?
          needs_update?(show) ? update_show_from_kitsu!(show) : show
        else
          create_show_from_kitsu!
        end

        sync_show_images!(show)
        refresh_show_urls!(show)

        raise NSFWError if show.nsfw? && !allows_nsfw?
        show
      end

      private

      def update_show_from_kitsu!(show)
        return unless force_update || show.status != 'airing'

        results = search_results[:attributes]

        show.assign_attributes(show_options(results))
        show.title = Title.new(show_title_options(results))
        show.description = Description.new({ en: (results[:synopsis].presence || results[:description].presence || '- No description -') })
        # show.cover.assign_attributes(results[:coverImage].except(:meta)) if results[:coverImage]
        # show.poster.assign_attributes(results[:posterImage].except(:meta)) if results[:posterImage]
        show.save!

        streaming_platforms_from_anilist!(search_results, show)
        try_adding_images(show, results)

        # show.tags = show_tags

        show
      end

      def create_show_from_kitsu!
        new_show = build_show_from(search_results[:attributes])

        new_show.reference_id = search_results[:id]
        new_show.reference_source = :kitsu
        new_show.show_type = search_results[:type]
        # new_show.url = search_results.dig(:links, :self)
        new_show.save!

        streaming_platforms_from_anilist!(search_results, new_show)
        try_adding_images(new_show, search_results[:attributes], force: true)

        new_show
      end

      def search_results
        return @search_results if @search_results.present?

        search_results = ::Kitsu::ApiRequest.perform(
          endpoint: "/anime/#{kitsu_id}",
          params: { include: 'categories,mappings' }
        )

        raise NotFound, "Show with ID: #{kitsu_id} was not found" unless search_results

        @included = search_results[:included]
        @search_results = search_results[:data]
      end

      def needs_update?(show)
        force_update ||
          (show.persisted? && !show.valid?) ||
          show.status == 'airing' ||
          show.urls.empty? ||
          # show.tags.empty? ||
          show.nsfw? ||
          !show.banner.attached? ||
          !show.poster.attached?
      end
    end
  end
end
