class SubscriptionTarget < ApplicationRecord
  belongs_to :user_subscription

  after_create :notify_user_of_creation!

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

  def info
    { targetable_id: targetable_id, targetable_type: targetable_type }
  end

  private

  def notify_user_of_creation!
    require 'discordrb'

    info = model.human_friendly_data
    embed = Discordrb::Webhooks::Embed.new(
      title: "New subscription",
      description: "You've successfully subscribed to the #{info[:subscription_type]} for #{info[:model_title]}."
    )

    Subscriptions::Discord::Bot.send(user_subscription, embed)
  end
end
