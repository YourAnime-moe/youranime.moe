class Title < ApplicationRecord
  include TranslatableConcern

  validate :title_present

  translates :value, through: [:en, :fr, :jp], default: :en

  private
  
  def title_present
    errors.add(:value, 'must be present (one of en, fr, jp)') unless value.present?
  end
end
