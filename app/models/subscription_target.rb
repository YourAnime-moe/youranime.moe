class SubscriptionTarget < ApplicationRecord
  belongs_to :user_subscription

  def notify!(action, model = nil, changes: [])
    if user_subscription.platform == "discord"
      unless user_subscription.platform_user_id
        Rails.logger.error("Missing Discord user id")
        return
      end

      return unless is?(model)

      Rails.logger.info("Notifying discord user #{user_subscription.platform_user_id}")
      Rails.logger.info("Action #{action}. Data #{model.as_json}. Changes: #{changes}")

      Subscriptions::Discord::Notifier.new(user_subscription).notify(action, model, changes)
    end
  end

  def is?(model)
    self.model == model
  end

  def model
    @model ||= targetable_type.constantize.find(targetable_id)
  end
end
