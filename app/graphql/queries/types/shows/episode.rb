# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Episode < ::Types::BaseObject
        field :url, String, null: false
        field :name, String, null: false
        field :img, String, null: false
        field :number, Integer, null: true
      end
    end
  end
end
