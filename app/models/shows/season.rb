module Shows
  class Season < ApplicationRecord
    belongs_to :show
    has_many :episodes, -> { order(:number) }, dependent: :delete_all
    has_many :published_episodes, -> { published.order(:number) }, class_name: 'Episode', dependent: :delete_all
    has_many :all_episodes, -> { all }, class_name: "Episode", dependent: :delete_all

    def default_name
      "Season #{number}"
    end
  end
end
