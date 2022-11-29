module Subscriptions
  class BaseNotifier
    attr_reader :user_subscription

    def initialize(user_subscription)
      @user_subscription = user_subscription
    end

    def notify(action, model)
      raise NotImplementedError
    end
  end
end
