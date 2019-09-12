module Shows
  class Season < ApplicationRecord
    include ConnectsToShowsConcern

    belongs_to :show
  end
end
