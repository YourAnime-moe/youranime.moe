# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Poster < ::Types::BaseObject
        field :original, String, null: false
        field :large, String, null: true
        field :medium, String, null: true
        field :small, String, null: true
        field :tiny, String, null: true
      end
    end
  end
end
