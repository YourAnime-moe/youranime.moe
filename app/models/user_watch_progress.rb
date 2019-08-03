# frozen_string_literal: true

class UserWatchProgress < ApplicationRecord
  belongs_to :episode, class_name: 'Episode', optional: false
  belongs_to :user, optional: false
  has_one :show, through: :episode

  before_save :check_progress

  private

  def check_progress
    current_progress = self.class.where(
      user_id: user_id,
      episode_id: episode_id
    )
    throw :abort if current_progress.empty?
    self.progress = 0.0 if progress.nil? || progress.negative?
  end
end
