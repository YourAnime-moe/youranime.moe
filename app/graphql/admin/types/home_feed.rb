# frozen_string_literal: true
module Admin
  module Types
    class HomeFeed < ::Types::BaseObject
      field :shows, Integer, null: false
      field :jobs_running, Integer, null: false
      field :users, Integer, null: false
      field :admin_users, Integer, null: false
      field :issues, Integer, null: false
    end
  end
end
