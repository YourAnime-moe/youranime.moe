# frozen_string_literal: true
module Home
  module Categories
    module Providers
      class Default
        # Order matters ;)
        USE_CATEGORIES = [
          Home::Categories::ComingUpNext,
          Home::Categories::TopThisSeason,
          Home::Categories::TopComingSoon,
          Home::Categories::TopAiringNow,
          Home::Categories::FromLastSeason,
          Home::Categories::BestOfAllTime,
          Home::Categories::Platforms::NewOnFunimation,
        ].freeze

        def self.categories(context:)
          USE_CATEGORIES.map do |category_class|
            category = category_class.new(context: context)
            next unless category.visible?

            category
          end.compact
        end
      end
    end
  end
end
