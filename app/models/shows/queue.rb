module Shows
  class Queue < ApplicationRecord
    include ConnectsToUsersConcern
  
    belongs_to :user, inverse_of: :queues
  end  
end
