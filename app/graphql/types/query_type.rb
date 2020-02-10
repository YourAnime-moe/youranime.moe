# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include Types::Queries::General

    field :current_user, Types::Accounts::User, null: true
    def current_user
      p context[:session]
      context[:current_user]
    end

    # Main page
    field :main_queue, [Types::Media::Show], null: true
    field :discover, [Types::Media::Show], null: false do
      argument :limit, Int, required: false
    end
    field :trending, [Types::Media::Show], null: false do
      argument :limit, Int, required: false
    end

    # All shows page
    field :all_shows, [Types::Media::Show], null: false
    field :shows_connection, Types::Media::Show.connection_type, null: false

    # View show page
    field :show, Types::Media::Show, null: true do
      argument :show_id, Int, required: true
    end
    field :seasons, [Types::Media::Shows::Season], null: false do
      argument :show_id, Int, required: true
    end

    # View episode page
    field :episode, Types::Media::Shows::Episode, null: true do
      argument :id, Int, required: true
    end

    # Misc pages
    field :search_show, [Types::Media::Show], null: false do
      argument :title, String, required: true
      argument :limit, Int, required: false
    end
  end
end
