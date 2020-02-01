module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :current_user, Types::Accounts::User, null: true
    def current_user
      context[:current_user]
    end

    # TODO: paginate
    field :all_shows, [Types::Media::Show], null: false
    def all_shows
      current_user&.admin? ? Show.all : Show.published
    end
  end
end
