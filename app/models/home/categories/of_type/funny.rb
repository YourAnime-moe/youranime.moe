# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class Funny < BaseCategory
        def title_template
          "categories.of_type.funny.title"
        end

        def enabled?
          true
        end

        def scopes
          [:trending]
        end

        def self.default_scope
          Show.by_tags(:comedy)
        end
      end
    end
  end
end
