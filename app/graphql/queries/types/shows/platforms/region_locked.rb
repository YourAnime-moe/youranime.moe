# frozen_string_literal: true
module Queries
  module Types
    module Shows
      module Platforms
        class RegionLocked < ::Types::BaseScalar
          description "A valid representation of a region locked scalar. If true, it returns the {for_country: string}."

          def self.coerce_input(input_value, context)
            { for_country: input_value ? context[:country] : nil }
          end
        end
      end
    end
  end
end
