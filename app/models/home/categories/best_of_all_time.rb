# frozen_string_literal: true
module Home
  module Categories
    class BestOfAllTime < BaseCategory
      def title_template
        'categories.best_of_all_time.title'
      end

      def scopes
        [:trending]
      end

      def enabled?
        true
      end
    end
  end
end
