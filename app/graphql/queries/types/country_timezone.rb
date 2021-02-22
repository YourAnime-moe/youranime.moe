# frozen_string_literal: true
module Queries
  module Types
    class CountryTimezone < ::Types::BaseObject
      field :country, String, null: true
      field :timezone, String, null: true
    end
  end
end
