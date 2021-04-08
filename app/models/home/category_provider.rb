# frozen_string_literal: true
module Home
  class CategoryProvider
    # Order matters ;)
    USE_CATEGORIES = [
      Home::ComingUpNextCategory,
      Home::TopThisSeasonCategory,
      Home::TopComingSoonCategory,
      Home::TopAiringNowCategory,
      Home::FromLastSeasonCategory,
    ].freeze

    def self.categories(context:)
      offset = 0 unless offset

      USE_CATEGORIES.map do |category_class|
        category = category_class.new(context: context)
        next unless category.visible?

        category
      end.compact
    end
  end
end
