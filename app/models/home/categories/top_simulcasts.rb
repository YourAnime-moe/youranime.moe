# frozen_string_literal: true
module Home
  module Categories
    class TopSimulcasts < Home::Categories::BaseCategory
      def title_template
        "categories.top_simulcasts.title"
      end

      def key
        'top-simulcasts'
      end

      def title_params
        { country: ISO3166::Country.new(context[:country]) }
      end

      def enabled?
        true
      end

      def layout
        :expanded
      end

      def thumbnail_attributes
        [:next_episode, :airing_at]
      end

      def cache_expires_in
        10.minutes
      end

      def self.default_scope
        Shows::Streamable.perform(airing: true, sort_filters: :airing_at)
      end
    end
  end
end
