module Shows
  class Season < ApplicationRecord
    belongs_to :show
    has_many :episodes, -> { published.order(:title) }
    has_many :all_episodes, -> { all }, class_name: "Episode"
  end
end
