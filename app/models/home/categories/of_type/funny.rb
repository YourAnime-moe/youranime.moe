# frozen_string_literal: true
module Home
  module Categories
    module OfType
      class Funny < BaseCategory
        def self.default_scope
          Show.by_tags(:comedy)
        end
      end
    end
  end
end
