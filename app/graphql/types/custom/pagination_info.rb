# frozen_string_literal: true
module Types
  module Custom
    class PaginationInfo < GraphQL::Types::Relay::BaseObject
      field :has_next_page, Boolean, null: false
      field :has_previous_page, Boolean, null: false
      field :total_count, Integer, null: false
      field :total_pages, Integer, null: false

      def total_count
        if object.respond_to?(:relation_count)
          object.relation_count(object.items)
        elsif object.respond_to?(:nodes)
          object.nodes.count
        else
          -1
        end
      end
    end
  end
end
