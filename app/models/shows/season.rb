module Shows
  class Season < ApplicationRecord
    include ConnectsToShowsConcern
  end
end
