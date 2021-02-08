# frozen_string_literal: true
module Types
  module Custom
    class BaseConnection < GraphQL::Types::Relay::BaseConnection
      # class << self
      #   def edge_type(
      #     edge_type_class,
      #     edge_class: GraphQL::Relay::Edge,
      #     node_type: edge_type_class.node_type,
      #     nodes_field: true
      #   )
      #     super(edge_type_class, edge_class: edge_class, node_type: node_type, nodes_field: nodes_field)
      #   end
      # end

      field :page_info, Types::Custom::PaginationInfo, null: false
    end
  end
end
