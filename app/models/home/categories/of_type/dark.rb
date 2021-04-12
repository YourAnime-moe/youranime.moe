# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class Dark < BaseCategory
        def title_template
          "categories.of_type.dark.title"
        end

        def enabled?
          true
        end

        def scopes
          [:trending]
        end

        def self.default_scope
          Show.by_tags(:thriller, :horror)
            .or(Show.by_tags(:drama, :thriller)
              .or(Show.by_tags(:thriller, :drama)
                .or(Show.by_tags(:psychological))))
        end
      end
    end
  end
end
