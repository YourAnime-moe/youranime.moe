# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class EverydayLife < BaseCategory
        def title_template
          "categories.of_type.everyday_life.title"
        end

        def enabled?
          true
        end

        def self.default_scope
          Show.by_tags(:slice_of_life)
        end
      end
    end
  end
end
