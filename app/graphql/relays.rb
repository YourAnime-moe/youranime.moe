# frozen_string_literal: true
module Relays
  GraphQL::Relay::BaseConnection.register_connection_implementation(
    ApplicationRecord,
    Types::Custom::Connection::ApplicationRecordConnection,
  )

  GraphQL::Relay::ConnectionType.bidirectional_pagination = true
end
