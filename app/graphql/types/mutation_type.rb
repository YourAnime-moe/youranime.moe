module Types
  class MutationType < Types::BaseObject
    field :signin_user, mutation: Mutations::Accounts::CreateSession
  end
end
