# frozen_string_literal: true
module Home
  module Categories
    module Providers
      class Default
        # Order matters ;)
        HOME_PAGE_CATEGORIES = [
          Home::Categories::TopSimulcasts,
          Home::Categories::TopThisSeason,
          Home::Categories::TopComingSoon,
          Home::Categories::FromLastSeason,
        ].freeze

        PLATFORM_CATEGORIES = [
          Home::Categories::Platforms::NewOnCrunchyroll,
          Home::Categories::Platforms::NewOnVrv,
          Home::Categories::Platforms::NewOnFunimation,
          Home::Categories::Platforms::NewOnAnimelab,
          Home::Categories::Platforms::NewOnHidive,
          Home::Categories::Platforms::NewOnHulu,
          Home::Categories::Platforms::NewOnPrime,
          Home::Categories::Platforms::NewOnNetflix,
          Home::Categories::Platforms::NewOnTubi,
        ].freeze

        OTHER_CATEGORIES = [
          Home::Categories::Platforms::ExclusiveOnCrunchyroll,
          Home::Categories::Platforms::ExclusiveOnNetflix,
          Home::Categories::Platforms::ExclusiveOnFunimation,
          # Home::Categories::OfType::Romance,
          # Home::Categories::OfType::Funny,
          # Home::Categories::OfType::Exciting,
          # Home::Categories::OfType::Dark,
          # Home::Categories::OfType::EverydayLife,
          # Home::Categories::OfType::ScienceFiction,
          # Home::Categories::MusicVideos,
          # Home::Categories::TopAiringNow,
          # Home::Categories::BestOfAllTime,
        ].freeze

        def self.main_categories_classes
          HOME_PAGE_CATEGORIES + PLATFORM_CATEGORIES
        end

        def self.all_categories_classes
          HOME_PAGE_CATEGORIES + OTHER_CATEGORIES
        end

        def self.categories(context:, include_others: false)
          categories_classes = include_others ? all_categories_classes : main_categories_classes

          categories_classes.map do |category_class|
            category = category_class.new(context: context)
            next unless category.visible?

            category.validate!
            category
          end.compact
        end

        def self.find_category(key, context:, include_others: false)
          categories(context: context, include_others: include_others).find do |category|
            category.key.to_s == key.to_s
          end
        end
      end
    end
  end
end
