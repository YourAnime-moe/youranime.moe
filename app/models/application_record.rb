class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :primary, reading: :primary_replica }

  def errors_string(default=nil)
    return default unless errors.any?
    errors.to_a.join(', ')
  end
end
