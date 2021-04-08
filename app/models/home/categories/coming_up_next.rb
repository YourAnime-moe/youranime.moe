# frozen_string_literal: true
module Home
  module Categories
    class ComingUpNext < Home::Categories::BaseCategory
      def title_template
        "categories.coming_up_next.title"
      end

      def title_params
        { country: ISO3166::Country.new(context[:country]) }
      end

      def enabled?
        true
      end
    end
  end
end
