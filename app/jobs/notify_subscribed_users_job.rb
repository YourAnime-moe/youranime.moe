class NotifySubscribedUsersJob < TrackableJob
  queue_as :batch_queue

  def perform(action, target_ids, model_class, model_id)
    model = model_class.safe_constantize&.find(model_id)
    if model.nil?
      raise ArgumentError.new("Invalid model. Could not find a model with #{model_class}.find(#{model_id})")
    end

    target_ids.each do |target_id|
      subscription_target = SubscriptionTarget.find(target_id)
      subscription_target.notify!(action, model)
    end
  end
end
