# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Tag < ::Types::BaseObject
        field :tag_type, String, null: false
        field :value, String, null: false
        field :ref_url, String, null: true
        field :ref_id, String, null: true
      end
    end
  end
end
