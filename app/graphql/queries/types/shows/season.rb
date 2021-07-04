# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Season < ::Types::BaseObject
        field :season, String, null: true
        field :episodes, Episode.connection_type, null: false
      end
    end
  end
end
