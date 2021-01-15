# frozen_string_literal: true
module Utilities
  module Dates
    class DaysOfWeek < ApplicationOperation
      DAYS_OF_WEEK = %i(sunday monday tuesday wednesday thursday friday saturday)

      property! :date, converts: :to_date
      property :first_day, accepts: DAYS_OF_WEEK, default: :sunday

      def perform
        current_date = date.beginning_of_week(first_day)

        dates = []
        7.times.each do |i|
          dates << current_date + i.days
        end

        dates
      end
    end
  end
end
