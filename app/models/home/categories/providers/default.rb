# frozen_string_literal: true
module Home
  module Categories
    module Providers
      class Default
        # Order matters ;)

        PRIMARY_CATEGORIES = [
          Home::Categories::FeaturedShow,
          Home::Categories::WatchList,
          Home::Categories::FollowingOnDiscord,
        ]
        
        BASIC_CATEGORIES = [
          Home::Categories::TopComingSoon,
          Home::Categories::Platforms::NewOnCrunchyroll,
          Home::Categories::Platforms::NewOnVrv,
          Home::Categories::Platforms::NewOnFunimation,
          Home::Categories::Platforms::NewOnAnimelab,
          Home::Categories::Platforms::NewOnHidive,
          Home::Categories::TopSimulcasts,
          Home::Categories::Platforms::NewOnHulu,
          Home::Categories::Platforms::NewOnPrime,
          Home::Categories::Platforms::NewOnNetflix,
          Home::Categories::Platforms::NewOnTubi,
          Home::Categories::TopThisSeason,
        ].freeze

        OTHER_CATEGORIES = [
          # Home::Categories::Platforms::ExclusiveOnCrunchyroll,
          # Home::Categories::Platforms::ExclusiveOnNetflix,
          # Home::Categories::Platforms::ExclusiveOnFunimation,
          Home::Categories::OfType::Romance,
          Home::Categories::OfType::Funny,
          Home::Categories::OfType::Exciting,
          Home::Categories::FromLastSeason,
          Home::Categories::OfType::Dark,
          Home::Categories::OfType::EverydayLife,
          Home::Categories::OfType::ScienceFiction,
          Home::Categories::MusicVideos,
          Home::Categories::TopAiringNow,
          Home::Categories::BestOfAllTime,
        ].freeze

        def self.main_categories_classes
          PRIMARY_CATEGORIES + BASIC_CATEGORIES
        end

        def self.all_categories_classes
          PRIMARY_CATEGORIES + BASIC_CATEGORIES + OTHER_CATEGORIES
        end

        def self.categories(context:, filters: {}, include_others: false)
          categories_classes = include_others ? all_categories_classes : main_categories_classes

          categories_classes.map do |category_class|
            category = category_class.new(context: context, filters: filters)
            next unless category.visible?

            category.validate!
            category
          end.compact
        end

        def self.find_category(key, context:, filters: {}, include_others: false)
          categories(context: context, filters: filters, include_others: include_others).find do |category|
            category.key.to_s == key.to_s
          end
        end
      end
    end
  end
end
