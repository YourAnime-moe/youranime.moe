class Description < ApplicationRecord
  include TranslatableConcern

  validate :description_present

  translates :value, through: [:en, :fr, :jp], default: :en

  private
  
  def description_present
    errors.add(:value, 'must be present (one of en, fr, jp)') unless value.present?
  end
end
