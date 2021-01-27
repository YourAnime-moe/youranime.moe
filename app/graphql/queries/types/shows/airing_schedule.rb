# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class AiringSchedule < ::Types::BaseObject
        field :airing_at, Int, null: false
        field :time_until_airing, Int, null: false
        field :episode, Int, null: false
      end
    end
  end
end
