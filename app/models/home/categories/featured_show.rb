# frozen_string_literal: true
module Home
  module Categories
    class FeaturedShow < BaseCategory
      def title_template
        "categories.featured_show.title"
      end

      def layout
        :featured
      end

      def enabled?
        Show.any?
      end

      def shows_override
        # if context[:current_user].present?
        #   show = context[:current_user].main_queue.shows.first
        #   return Show.where(slug: show.slug) if show
        # end
        streamable = Shows::Streamable.perform(airing: true, sort_filters: :airing_at)
        return Show.none unless streamable.any?

        show = streamable.first
        Show.where(slug: show.slug)
      end

      def cacheable?
        false
      end
    end
  end
end

