# frozen_string_literal: true
module Admin
  module Types
    class JobEvent < ::Types::BaseObject
      include ActionView::Helpers::DateHelper

      connection_type_class ::Types::Custom::BaseConnection

      field :id, ID, null: false
      field :status, Admin::Types::JobEventStatus, null: false
      field :job_name, String, null: false
      field :started_at, Integer, null: false
      field :ended_at, Integer, null: true
      field :ran_for, String, null: true
      field :started_ago, String, null: false
      field :ended_ago, String, null: true
      field :job_id, String, null: true
      field :model_id, Integer, null: true
      field :used_by_model, String, null: true
      field :failed_reason_key, String, null: true
      field :failed_reason_text, String, null: true
      field :backtrace, String, null: true
      field :user, Admin::Types::User, null: true

      def started_ago
        time_ago_in_words(@object.started_at)
      end

      def ended_ago
        time_ago_in_words(@object.ended_at) if @object.ended_at
      end

      def ran_for
        return unless @object.started_at

        end_date = @object.ended_at || DateTime.now
        distance_of_time_in_words(end_date - @object.started_at)
      end
    end
  end
end

