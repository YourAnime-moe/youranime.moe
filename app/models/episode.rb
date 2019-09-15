class Episode < ApplicationRecord
  include ResourceFetchConcern
  include ConnectsToEpisodesConcern

  belongs_to :season, -> { connected_to(role: :reading) { all } }, class_name: 'Shows::Season'

  has_one_attached :video
  has_one_attached :thumbnail
  has_resource :thumbnail, default_url: '/img/404.jpg', expiry: 3.days
  has_resource :video, default_url: '/img/404.mp4', expiry: 500.minutes

  def show
    @show ||= season.show
  end

  def unrestricted?
    episodes = show&.episodes
    !episodes.nil? && episodes[0..2].include?(self)
  end

  def subtitles?
    false
  end
end
