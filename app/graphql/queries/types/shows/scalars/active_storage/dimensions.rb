# frozen_string_literal: true
module Queries
  module Types
    module Shows
      module Scalars
        module ActiveStorage
          class Dimensions < ::Types::BaseScalar
            def self.coerce_input(value, _context)
              value = value.to_h.with_indifferent_access
              return unless value.is_a?(Hash)

              width = value[:width]
              height = value[:height]

              return if width.blank? || height.blank?

              [width, height].join('x')
            end
          end
        end
      end
    end
  end
end
