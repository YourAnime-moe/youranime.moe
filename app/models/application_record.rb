class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def errors_string(default=nil)
    return default unless errors.any?
    errors.to_a.join(', ')
  end
end
