# frozen_string_literal: true
module Shows
  module Kitsu
    module Sync
      class Airing < ::Kitsu::ApplicationOperation
        property! :season, accepts: %i(current next), converts: :to_sym
        property! :requested_by, accepts: Users::Admin

        def perform
          fetch_airing_shows
        end

        private

        def fetch_airing_shows
          shows = []
          @current_page = 1

          loop do
            shows_options = search_results[:data]
            break if shows_options.empty?

            shows_options.each do |results|
              results.merge!({ synched_by: requested_by.id })
              show = find_or_create_show!(results, :kitsu)
              streaming_platforms_from_anilist(results, show)

              shows << show
            end

            @current_page += 1
          end

          shows.each do |show|
          end

          shows
        end

        def streaming_platforms_from_anilist(results, show)
          anilist_id = anilist_id_from(results)
          return unless anilist_id.present?

          show_urls = Shows::Anilist::Streamers.perform(
            anilist_id: anilist_id,
            show: show,
            persist: true,
          )
          show.urls = show_urls if show_urls.present?

          show_urls
        end

        def anilist_id_from(results)
          results.dig(:relationships, :mappings, :data).map do |data|
            next unless data[:type] == 'mappings'

            @included.filter do |included_data|
              included_data[:type] == 'mappings' &&
                data[:id] == included_data[:id] &&
                included_data.dig(:attributes, :externalSite) =~ /anilist/
            end.map do |included_data|
              included_data.dig(:attributes, :externalId)
            end
          end.compact.flatten.first
        end

        def search_results
          @search_results = ::Kitsu::ApiRequest.perform(
            endpoint: '/anime',
            params: {
              filter: {
                season: requested_season[:season],
                seasonYear: requested_season[:year],
              },
              page: {
                limit: 20,
                offset: @current_page * 20,
              },
              include: 'mappings,genres',
            },
          )

          @included = @search_results[:included]
          @search_results
        end

        def requested_season
          Config.send("#{season}_season")
        end
      end
    end
  end
end
