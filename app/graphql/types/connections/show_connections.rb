# frozen_string_literal: true

module Types
  module Connections
    class ShowsEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::Media::Show)
    end

    class ShowConnections < GraphQL::Types::Relay::BaseConnection
      field :total_count, Integer, null: false
      def total_count
        object.count
      end

      edge_type(ShowsEdgeType)
    end
  end
end
