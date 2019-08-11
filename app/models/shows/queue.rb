module Shows
  class Queue < ApplicationRecord
    include ConnectsToUsersConcern
  
    belongs_to :user, inverse_of: :queues
    has_many :shows_queue_relations
  end  
end
