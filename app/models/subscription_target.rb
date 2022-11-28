class SubscriptionTarget < ApplicationRecord
  belongs_to :user_subscription

  def notify!(action, model = nil)
    if user_subscription.platform == "discord"
      unless user_subscription.platform_user_id
        Rails.logger.error("Missing Discord user id")
        return
      end

      return if model != self.model

      Rails.logger.info("Notifying discord user #{user_subscription.platform_user_id}")
      Rails.logger.info("Action #{action}. Data #{model.as_json}")
    end
  end

  def model
    @model ||= targetable_type.constantize.find(targetable_id)
  end
end
