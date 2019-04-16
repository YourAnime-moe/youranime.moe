class UserWatchProgress < ApplicationRecord
  belongs_to :episode, class_name: 'Episode'
  belongs_to :user

  before_save :check_progress

  private

  def check_progress
    current_progress = self.class.where(
      user_id: user_id,
      episode_id: episode_id
    )
    #throw :abort if current_progress.size > 0
    self.progress = 0.0 if self.progress.nil? || self.progress < 0
  end
end
