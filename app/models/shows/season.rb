module Shows
  class Season < ApplicationRecord
    include ConnectsToShowsConcern

    belongs_to :show
    has_many :episodes
  end
end
