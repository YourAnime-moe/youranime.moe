# frozen_string_literal: true
module Queries
  module Types
    class FriendlyDatetime < ::Types::BaseScalar
      description "A human-readable representation of date and time based on the current timezone."

      def self.coerce_result(ruby_value, context)
        Time.use_zone(context[:timezone]) do
          datetime = ruby_value.to_datetime.in_time_zone

          datetime.strftime("%b %-d, %Y at %H:%M")
        end
      end
    end
  end
end
