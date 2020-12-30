# frozen_string_literal: true
module Shows
  module Kitsu
    class Search < ApplicationOperation
      property! :query, accepts: String

      def perform
        Shows::Kitsu::Sync::ShowsPerPage.perform(
          params: {
            filter: {
              text: query,
            },
            include: 'mappings,genres',
          },
          max_page: 6,
          per_page: 8,
          requested_by: Users::Admin.system,
        )
      end
    end
  end
end
