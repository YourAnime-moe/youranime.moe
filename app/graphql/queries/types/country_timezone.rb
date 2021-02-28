# frozen_string_literal: true
module Queries
  module Types
    class CountryTimezone < ::Types::BaseObject
      field :country, Queries::Types::Shows::Platforms::Country, null: false
      field :timezone, String, null: false
      field :is_default, Boolean, null: false

      def is_default
        context[:is_default]
      end
    end
  end
end
