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
          )
        end

        private

        def requested_season
          Config.send("#{season}_season")
        end
      end
    end
  end
end
