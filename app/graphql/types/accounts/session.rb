# frozen_string_literal: true

module Types
  module Accounts
    class Session < BaseObject
      field :token, String, null: false
      field :active_since, GraphQL::Types::ISO8601Date, null: false
      field :active_until, GraphQL::Types::ISO8601Date, null: false
      field :deleted, GraphQL::Types::Boolean, null: false
      field :deleted_on, GraphQL::Types::ISO8601Date, null: true
    end
  end
end
