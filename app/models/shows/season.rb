module Shows
  class Season < ApplicationRecord
    belongs_to :show
    has_many :episodes, -> { published.order(:number) }
    has_many :all_episodes, -> { all }, class_name: "Episode"
  end
end
