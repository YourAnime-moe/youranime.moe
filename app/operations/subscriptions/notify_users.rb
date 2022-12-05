module Subscriptions
  class NotifyUsers < ApplicationOperation
    property! :model
    property! :action, accepts: [:create, :update, :delete]
    property! :subscription_type
    property :changes

    def execute
      subscriptions = model.subscriptions
      return unless subscriptions.any?

      target = model.targets.to_a.find do |target|
        target.is?(model)
      end

      return unless target.present?

      NotifySubscribedUsersJob.perform_later(action, target.id, model.class.name, model.id, changes)
    end

    private

    def subscription_targets
      user_subscription_ids = UserSubscription.where(subscription_type: subscription_type).ids
      SubscriptionTarget.where(user_subscription_id: user_subscription_ids)
    end
  end
end
