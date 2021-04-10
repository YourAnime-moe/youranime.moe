# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class ScienceFiction < BaseCategory
        def title_template
          "categories.of_type.scifi.title"
        end

        def enabled?
          true
        end

        def self.default_scope
          Show.by_tags(:science_fiction)
        end
      end
    end
  end
end
