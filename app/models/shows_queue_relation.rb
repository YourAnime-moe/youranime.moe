class ShowsQueueRelation < ApplicationRecord
  include ConnectsToShowsConcern
  
  belongs_to :show

  def queue
    Shows::Queue.connected_to(role: :reading) do
      Shows::Queue.where(id: queue_id)
    end
  end
end
