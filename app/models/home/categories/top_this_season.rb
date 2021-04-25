# frozen_string_literal: true
module Home
  module Categories
    class TopThisSeason < Home::Categories::BaseCategory
      def title_template
        "categories.top_this_season.title"
      end

      def scopes
        [:trending, :new_this_season]
      end

      def enabled?
        true
      end
    end
  end
end