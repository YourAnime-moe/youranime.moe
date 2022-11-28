class UserSubscription < ApplicationRecord
  has_many :targets, class_name: 'SubscriptionTarget'

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
end
