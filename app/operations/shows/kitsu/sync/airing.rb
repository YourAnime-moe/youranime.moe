# frozen_string_literal: true
module Shows
  module Kitsu
    module Sync
      class Airing < ::Kitsu::ApplicationOperation
        property! :season, accepts: %i(current next), converts: :to_sym

        def perform
          Shows::Kitsu::Sync::ShowsPerPage.perform(
            params: {
              filter: {
                season: requested_season[:season],
                seasonYear: requested_season[:year],
              },
              include: 'mappings,genres',
            },
            max_page: 0,
            requested_by: Users::Admin.system,
            update_if_found: true,
          )
        end

        private

        def query
          <<- GRAPHQL
            query KitsuAiringAndComingSoon($after: String) {
              animeByStatus(status: CURRENT, after: $after, first: 1000) {
                totalCount
                pageInfo {
                  hasNextPage
                }
                
                edges {
                  node {
                    slug
                    titles {
                      alternatives
                      canonical
                      canonicalLocale
                      localized
                    }
                    ageRating
                    ageRatingGuide
                    bannerImage {
                      views {
                        url
                      }
                    }
                  }
                }
              }
            }
          GRAPHQL
        end

        def requested_season
          Config.send("#{season}_season")
        end
      end
    end
  end
end
