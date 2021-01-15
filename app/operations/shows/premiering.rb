# frozen_string_literal: true
module Shows
  class Premiering < ApplicationOperation
    # Accepts:
    # - Date, Time, DateTime (anything that responds to :to_date)
    # - :yesterday
    # - :today
    # - :tomorrow
    property! :date, converts: -> (date) {
      accepted_tags = [:today, :yesterday, :tomorrow]
      expected = ['Date object', 'object that responds to :to_date'] + accepted_tags
      if !date.is_a?(Date) && !date.respond_to?(:to_date) && !accepted_tags.include?(date)
        raise ArgumentError, "Expected: #{expected.join(', ')}"
      end

      date = date.try(:to_date) || date
      return date if date.is_a?(Date)

      return Time.current.to_date if date == :today
      return 1.day.ago.to_date if date == :yesterday
      return 1.day.from_now.to_date if date == :tomorrow

      raise ArgumentError, "Cannot convert :#{date} to Date object."
    }

    def perform
      Show.active.where(starts_on: date)
    end
  end
end
