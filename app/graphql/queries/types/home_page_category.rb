# frozen_string_literal: true
module Queries
  module Types
    class HomePageCategory < ::Types::BaseObject
      field :tags, [String], null: false
      field :title, String, null: false
      field :key, String, null: false
    end
  end
end
