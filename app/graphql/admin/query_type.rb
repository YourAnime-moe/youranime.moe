# frozen_string_literal: true
module Admin
  class QueryType < ::Types::BaseObject
    field :ping, type: String, null: false

    def ping
      'pong'
    end

    field :shows, type: Types::ShowRecord.connection_type, null: false do 
      argument :query, type: String, required: false
    end

    def shows(query: nil)
      if query.present?
        Search.perform(search: query, limit: 20, format: :shows)
      else
        Show.all.with_attached_poster
      end
    end
  end
end
