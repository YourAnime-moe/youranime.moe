# frozen_string_literal: true
class BatchOperationJob < ApplicationJob
  queue_as :batch_queue

  def perform(class_name, *args, **kwargs)
    operation_class = Object.const_get(class_name)
    operation = operation_class.new(*args, **kwargs)

    result = operation.perform
    Rails.logger.info("[BatchOperationJob][#{operation_class}] - Finished with result: #{result}")
    result
  end
end
