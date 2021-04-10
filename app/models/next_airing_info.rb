# frozen_string_literal: true
class NextAiringInfo < ApplicationRecord
  belongs_to :show

  scope :ordered, -> { order(:airing_at) }

  def past?
    is_past = Time.current >= airing_at || time_until_airing <= 0
    update!(past: is_past)

    is_past
  end

  def up_to_date!
    return self if past?

    update!(time_until_airing: (airing_at - Time.current).to_i)
    self
  end
end
