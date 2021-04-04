# frozen_string_literal: true
# This is only for input, for output, please use Queries::Types::Shows::Tag.

module Queries
  module Types
    module Shows
      module Scalars
        class TagFilter < ::Types::BaseScalar
          def self.coerce_input(input_value, _context)
            tag = ::Tag.find_by(value: input_value.to_s.strip.downcase)
            return tag if tag

            raise GraphQL::CoercionError, "#{input_value} is not a valid Tag value."
          end
        end
      end
    end
  end
end
