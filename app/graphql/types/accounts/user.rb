# frozen_string_literal: true

module Types
  module Accounts
    class User < BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :username, String, null: false
      field :email, String, null: true

      field :active, GraphQL::Types::Boolean, null: false
      field :limited, GraphQL::Types::Boolean, null: false

      field :hex, String, null: false

      field :google_token, String, null: true
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :sessions, [Types::Accounts::Session], null: false
      field :active_sessions, [Types::Accounts::Session], null: false
    end
  end
end
