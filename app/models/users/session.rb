module Users
  class Session < ApplicationRecord
    include ConnectsToShowsConcern
  end
end
