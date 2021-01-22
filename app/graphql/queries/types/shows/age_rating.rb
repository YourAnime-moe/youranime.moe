# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class AgeRating < ::Types::BaseObject
        field :rating, String, null: false
        field :guide, String, null: true
      end
    end
  end
end
