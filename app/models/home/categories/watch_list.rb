# frozen_string_literal: true
module Home
  module Categories
    class WatchList < BaseCategory
      def title_template
        "categories.watch_list.title"
      end

      def enabled?
        context[:current_user].try(:uuid).present?
      end

      def shows_override
        context[:current_user].main_queue.shows
      end
    end
  end
end
