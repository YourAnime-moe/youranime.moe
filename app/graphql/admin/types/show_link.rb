# frozen_string_literal: true
module Admin
  module Types
    class ShowLink < ::Types::BaseObject
      field :url_type, String, null: false
      field :value, String, null: false
      field :color, String, null: true
      field :platform, Queries::Types::Shows::Platform, null: true
    end
  end
end
