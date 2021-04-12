# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Link < ::Types::BaseObject
        field :url_type, String, null: false
        field :value, String, null: false
        field :color, String, null: true
        field :platform, Queries::Types::Shows::Platform, null: true

        def url_type
          @object.url_type.capitalize
        end
      end
    end
  end
end
