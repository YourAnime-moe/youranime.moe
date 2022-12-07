class UserSubscription < ApplicationRecord
  belongs_to :user, polymorphic: true
  has_many :targets, class_name: 'SubscriptionTarget'

  scope :with_user, -> do
    where.not(user_id: nil, user_type: nil)
  end

  def notify!(action, model)
    subscription_target = targets.find_by(
      targetable_type: model.class.name,
      targetable_id: model.id,
    )
    return unless subscription_target.present?

    subscription_target.notify!(action)
  end

  def build_target(model, expiry_condition: nil)
    SubscriptionTarget.new(
      user_subscription_id: id,
      targetable_id: model.id,
      targetable_type: model.class.name,
      expiry_condition: expiry_condition,
    )
  end

  def destination_id
    channel_id || platform_user_id
  end
end
