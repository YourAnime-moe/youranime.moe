# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class Romance < BaseCategory
        def title_template
          "categories.of_type.romance.title"
        end

        def enabled?
          true
        end

        def scopes
          [:trending]
        end

        def self.default_scope
          Show.by_tags(:romance)
        end
      end
    end
  end
end
