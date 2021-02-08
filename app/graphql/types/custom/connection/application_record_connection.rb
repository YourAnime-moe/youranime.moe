# frozen_string_literal: true
module Types
  module Custom
    module Connection
      class ApplicationRecordConnection < GraphQL::Relay::BaseConnection
        def total_count
          object.items.size
        end
      end
    end
  end
end
