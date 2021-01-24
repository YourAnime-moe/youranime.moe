# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Title < ::Types::BaseObject
        field :en, String, null: true
        field :jp, String, null: true
      end
    end
  end
end
