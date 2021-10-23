# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class KitsuResult < ::Types::BaseObject
        field :titles, ::Types::Custom::Map, null: false
        field :canonical_title, String, null: false
        field :slug, String, null: false
        field :poster_image, Shows::Poster, null: false
        field :status, String, null: false
        field :year, Integer, null: true
        field :nsfw, GraphQL::Types::Boolean, null: false
        field :platforms, [Shows::Platform], null: false do
          argument :focus_on, String, required: false
          argument :region_locked, Queries::Types::Shows::Platforms::RegionLocked, required: false
        end

        def platforms(focus_on: nil, region_locked: true)
          @object.platforms(focus_on: focus_on, for_country: (region_locked ? context[:country] : nil))
        end
      end
    end
  end
end

