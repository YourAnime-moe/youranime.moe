module Shows
  class Queue < ApplicationRecord
    include ConnectsToShowsConcern
  
    belongs_to :user, inverse_of: :queues
  end  
end
