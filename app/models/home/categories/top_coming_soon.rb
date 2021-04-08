# frozen_string_literal: true
module Home
  module Categories
    class TopComingSoon < Home::Categories::BaseCategory
      def title_template
        "categories.top_coming_soon.title"
      end

      def enabled?
        true
      end
    end
  end
end
