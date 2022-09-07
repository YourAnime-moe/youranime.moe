module Admin
  module Types
    class RunnableTask < ::Types::BaseObject
      field :name, String, null: false
      field :description, String, null: false
      field :operations, [Operation], null: false
    end
  end
end
