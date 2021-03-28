# frozen_string_literal: true
module Types
  module Custom
    class Map < ::Types::BaseScalar
      description 'A loose key-value map in GraphQL'

      def self.coerce_input(input_value, _context)
        input_value
      end

      def self.coerce_result(ruby_value, _context)
        ruby_value.as_json
      end
    end

    # Thank you https://github.com/hummingbird-me/kitsu-server
  end
end
