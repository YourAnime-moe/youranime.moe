# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Link < ::Types::BaseObject
        field :url_type, String, null: false
        field :value, String, null: false
        field :platform, Queries::Types::Shows::Platform, null: true
      end
    end
  end
end
