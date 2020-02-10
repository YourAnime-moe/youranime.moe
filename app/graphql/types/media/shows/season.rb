# frozen_string_literal: true

module Types
  module Media
    module Shows
      class Season < BaseObject
        field :number, Int, null: false
        field :name, String, null: true

        field :episodes, [Episode], null: false
      end
    end
  end
end
