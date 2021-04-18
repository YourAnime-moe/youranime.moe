# frozen_string_literal: true
module Queries
  module Types
    class ShowsByYear < ::Types::BaseObject
      field :year, Integer, null: false
      field :shows, Queries::Types::Show.connection_type, null: false
    end
  end
end
