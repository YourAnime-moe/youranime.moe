# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Filter < ::Types::BaseEnum
        value(
          "POPULARITY",
          "Sort a show by popularity (rank). The smaller the popularity, the more popular it is.",
          value: :popularity,
        )

        value(
          "TITLE",
          "Sort a show by title.",
          value: :title,
        )

        value(
          "START_DATE",
          "Sort a show by it's start date, i.e. when it started airing.",
          value: :starts_on,
        )
      end
    end
  end
end
