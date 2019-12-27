class Description < ApplicationRecord
  include TanoshimuUtils::Concerns::Translatable
  include TanoshimuUtils::Concerns::GetRecord

  validate :description_present
  validates :used_by_model, presence: true

  translates :value, through: [:en, :fr, :jp], default: :en

  private
  
  def description_present
    errors.add(:value, 'must be present (one of en, fr, jp)') unless value.present?
  end
end
