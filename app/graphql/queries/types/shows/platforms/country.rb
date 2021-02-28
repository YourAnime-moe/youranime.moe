# frozen_string_literal: true
module Queries
  module Types
    module Shows
      module Platforms
        class Country < ::Types::BaseScalar
          description "A valid representation of a country."

          def self.coerce_input(input_value, _context)
            country = ::ISO3166::Country.new(input_value)
            return country if country

            raise GraphQL::CoercionError, "#{input_value} is not a valid ISO 3166-1 alpha-2 code."
          end

          def self.coerce_result(ruby_value, context)
            preferred_alpha = context[:alpha] || 'alpha2'
            puts "\"#{ruby_value}\""
            object = ::ISO3166::Country.new(ruby_value.to_s.strip)

            {
              continent: object.continent,
              code: object.send(preferred_alpha),
              name: object.name,
            }
          end
        end
      end
    end
  end
end
