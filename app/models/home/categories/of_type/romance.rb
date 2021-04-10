# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class Romance < BaseCategory
        def self.default_scope
          Show.by_tags(:romance)
        end
      end
    end
  end
end
