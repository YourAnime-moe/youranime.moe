# frozen_string_literal: true
class ApplicationOperation < ActiveOperation::Base
  before do
    @start_time = Time.current
    Rails.logger.info("[#{self.class.name}] started at #{@start_time}...")
  end

  after do
    diff = Time.current - @start_time
    Rails.logger.info("[#{self.class.name}] finished in #{diff} s")
  end
end
