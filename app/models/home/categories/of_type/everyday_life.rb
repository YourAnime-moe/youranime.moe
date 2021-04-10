# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class Exciting < BaseCategory
        def self.default_scope
          Show.by_tags(:slice_of_life)
        end
      end
    end
  end
end
