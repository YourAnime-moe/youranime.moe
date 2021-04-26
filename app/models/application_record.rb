# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def unless(**args)
      where.not(**args)
    end
  end

  def errors_string(default = nil)
    return default unless errors.any?
    errors.to_a.join(', ')
  end
end
