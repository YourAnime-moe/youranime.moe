# frozen_string_literal: true
module Shows
  module Kitsu
    module Sync
      class ShowsPerPage < ::Kitsu::ApplicationOperation
        property! :params, accepts: Hash
        property! :requested_by, accepts: Users::Admin
        property :per_page, converts: :to_i, default: 20
        property :max_page, converts: :to_i, default: 10 # pass 0 to get all results
        property :raw, accepts: [true, false], default: false

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
              result = if raw
                results
              else
                results.merge!({ synched_by: requested_by.id })
                show = find_or_create_show!(results, :kitsu)
                streaming_platforms_from_anilist!(results, show)

                sync_show_images!(show)
                show  
              end

              shows << result
            end

            break if params.empty?
            break if limit_reached?

            @current_page += 1
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

        def kitsu_api_params
          params.merge!({
            page: {
              limit: per_page,
              offset: @current_page * per_page,
            },
          })
        end

        def offset
          @current_page * per_page
        end

        def limit_reached?
          max_page > 0 && max_page <= @current_page
        end
      end
    end
  end
end
