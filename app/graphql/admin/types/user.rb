module Admin
  module Types
    class User < ::Types::BaseObject
      field :id, ID, null: false
      field :username, String, null: false
    end
  end
end
