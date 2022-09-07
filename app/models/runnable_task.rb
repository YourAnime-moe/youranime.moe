# frozen_string_literal: true

class RunnableTask < FrozenRecord::Base
  def operations
    Operation.where(id: operation_ids)
  end
end
