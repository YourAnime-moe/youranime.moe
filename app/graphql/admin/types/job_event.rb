# frozen_string_literal: true
module Admin
  module Types
    class JobEvent < ::Types::BaseObject
      connection_type_class ::Types::Custom::BaseConnection

      field :id, ID, null: false
      field :status, Admin::Types::JobEventStatus, null: false
      field :job_name, String, null: false
      field :started_at, Integer, null: false
      field :ended_at, Integer, null: true
      field :job_id, Integer, null: true
      field :model_id, Integer, null: true
      field :used_by_model, String, null: true
      field :failed_reason_key, String, null: true
      field :failed_reason_text, String, null: true
      field :user, Admin::Types::User, null: true
    end
  end
end

