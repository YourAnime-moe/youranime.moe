module Admin
  module Types
    class Operation < ::Types::BaseObject
      field :constant_name, String, null: false
      field :github_link, String, null: false
    end
  end
end
