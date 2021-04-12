# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class Exciting < BaseCategory
        def title_template
          "categories.of_type.exciting.title"
        end

        def enabled?
          true
        end

        def scopes
          [:trending]
        end

        def self.default_scope
          Show.by_tags(:action, :drama).or(Show.by_tags(:action, :adventure))
        end
      end
    end
  end
end
