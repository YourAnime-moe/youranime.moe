# frozen_string_literal: true
module Home
  module Categories
    module Providers
      class Default
        # Order matters ;)
        BASIC_CATEGORIES = [
          Home::Categories::TopSimulcasts,
          Home::Categories::TopThisSeason,
          Home::Categories::TopComingSoon,
          Home::Categories::TopAiringNow,
          Home::Categories::FromLastSeason,
          Home::Categories::BestOfAllTime,
          Home::Categories::Platforms::ExclusiveOnCrunchyroll,
          Home::Categories::Platforms::NewOnCrunchyroll,
          Home::Categories::Platforms::ExclusiveOnNetflix,
          Home::Categories::Platforms::NewOnNetflix,
          Home::Categories::Platforms::ExclusiveOnFunimation,
          Home::Categories::Platforms::NewOnFunimation,
        ].freeze

        TAGGED_CATEGORIES = [
          Home::Categories::OfType::Exciting,
          Home::Categories::OfType::Dark,
        ].freeze

        def self.categories_classes
          BASIC_CATEGORIES + TAGGED_CATEGORIES
        end

        def self.categories(context:)
          categories_classes.map do |category_class|
            category = category_class.new(context: context)
            next unless category.visible?

            category.validate!
            category
          end.compact
        end
      end
    end
  end
end
