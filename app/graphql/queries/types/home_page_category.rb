# frozen_string_literal: true
# This is a view concern!
module Queries
  module Types
    class HomePageCategory < ::Types::BaseObject
      field :key, String, null: false
      field :title, String, null: false
      field :description, String, null: true
      field :warning, String, null: true
      field :layout, Queries::Types::Home::Categories::Layout, null: false
      field :shows, Queries::Types::Show.connection_type, null: false
      field :can_fetch_more, GraphQL::Types::Boolean, null: false
      field :featured_props, [Queries::Types::Categories::FeaturedProp], null: false

      def can_fetch_more
        @object.can_fetch_more?
      end
    end
  end
end
