# frozen_string_literal: true

module Types
  module Media
    class ShowType < BaseEnum
      graphql_name 'ShowType'
      description 'A type of show'

      ::Show::SHOW_TYPES.each do |show_type|
        value(show_type.upcase, value: show_type)
      end
    end
  end
end
