module Shows
  class Season < ApplicationRecord
    belongs_to :show
    has_many :episodes, -> { published }
    has_many :all_episodes, -> { all }, class_name: "Episode"
  end
end
