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

  def targets
    @targets ||= SubscriptionTarget.where(
      targetable_type: self.class.name,
      targetable_id: id,
    )
  end

  def subscriptions
    return @subscriptions if @subscriptions

    user_subscription_ids = targets.pluck(:user_subscription_id)
    @subscriptions = UserSubscription.where(id: user_subscription_ids)
  end

  def human_friendly_data
    {
      subscription_type: 'schedule',
      model_title: show.title,
      image: show.poster_url,
    }
  end

  private

  def notify_subscribed_users_create
    notify_subscribed_users(action: :create)
  end

  def notify_subscribed_users_update
    if previous_changes.key?(:episode_number)
      notify_subscribed_users(action: :update, changes: previous_changes.keys)
    end
  end

  def notify_subscribed_users(action:, changes: [])
    Subscriptions::NotifyUsers.perform(
      model: self,
      action: action,
      subscription_type: 'airing-info',
      changes: changes,
    )
  end
end
