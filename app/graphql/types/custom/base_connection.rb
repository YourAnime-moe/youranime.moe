# frozen_string_literal: true
module Types
  module Custom
    class BaseConnection < GraphQL::Types::Relay::BaseConnection
      field :page_info, Types::Custom::PaginationInfo, null: false
    end
  end
end
