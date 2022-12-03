# frozen_string_literal: true
class NextAiringInfo < ApplicationRecord
  belongs_to :show
  scope :ordered, -> { order(:airing_at) }

  after_update :notify_subscribed_users_update

  alias_attribute :next_episode, :episode_number

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

  private

  def notify_subscribed_users_create
    notify_subscribed_users(action: :create)
  end

  def notify_subscribed_users_update
    if previous_changes.any?
      notify_subscribed_users(action: :update)
    end
  end

  def notify_subscribed_users(action:)
    Subscriptions::NotifyUsers.perform(
      model: self,
      action: action,
      subscription_type: 'airing-info',
    )
  end
end
