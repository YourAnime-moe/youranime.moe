module Shows
  module Kitsu
    module Sync
      class Crawl < ApplicationOperation
        property! :years, accepts: Range

        def perform
          shows = []
          years.each do |year|
            Shows::Kitsu::Sync::ShowsPerPage.perform(
              params: {
                filter: {
                  seasonYear: year.to_s,
                },
              },
              per_page: 20,
              max_page: 0,
              requested_by: Users::Admin.system,
            )
          end
        end
      end
    end
  end
end
