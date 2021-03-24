# frozen_string_literal: true
class NextAiringInfo < ApplicationRecord
  belongs_to :show

  scope :ordered, -> { order(:airing_at) }

  def past?
    is_past = Time.current >= airing_at || time_until_airing <= 0
    update!(past: is_past)

    is_past
  end
end
