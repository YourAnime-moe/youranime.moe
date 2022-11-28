module Subscriptions
  class NotifyUsers < ApplicationOperation
    property! :model
    property! :action, accepts: [:create, :update, :delete]
    property! :subscription_type

    def execute
      subscription_targets.find_in_batches.each do |batch|
        NotifySubscribedUsersJob.perform_later(action, batch.map(&:id), model.class.name, model.id)
      end
    end

    private

    def subscription_targets
      user_subscription_ids = UserSubscription.where(subscription_type: subscription_type).ids
      SubscriptionTarget.where(user_subscription_id: user_subscription_ids)
    end
  end
end
