# frozen_string_literal: true
module Shows
  module Kitsu
    module Sync
      class ShowsPerPage < ::Kitsu::ApplicationOperation
        property! :kitsu_api_params, accepts: Hash
        property! :requested_by, accepts: Users::Admin

        def perform
          fetch_all_shows
        end

        private

        def fetch_all_shows
          shows = []
          @current_page = 1

          loop do
            shows_options = search_results[:data]
            break if shows_options.empty?

            shows_options.each do |results|
              results.merge!({ synched_by: requested_by.id })
              show = find_or_create_show!(results, :kitsu)
              streaming_platforms_from_anilist!(results, show)

              shows << show
            end

            break if kitsu_api_params.empty?

            @current_page += 1
          end

          shows.each do |show|
          end

          shows
        end

        def search_results
          @search_results = ::Kitsu::ApiRequest.perform(
            endpoint: '/anime',
            params: kitsu_api_params,
          )

          @included = @search_results[:included]
          @search_results
        end
      end
    end
  end
end
