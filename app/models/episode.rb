class Episode < ApplicationRecord
  include TanoshimuUtils::Concerns::ResourceFetch

  belongs_to :season, class_name: 'Shows::Season'

  has_one_attached :video
  has_one_attached :thumbnail
  has_resource :thumbnail, default_url: '/img/404.jpg', expiry: 3.days
  has_resource :video, default_url: '/img/404.mp4', expiry: 500.minutes

  scope :published, -> { where(published: true) }

  def show
    @show ||= season.show
  end

  def unrestricted?
    episodes = show&.episodes
    !episodes.nil? && episodes[0..2].include?(self)
  end

  def restricted?
    !unrestricted?
  end

  def subtitles?
    false
  end

  def subtitles
    []
  end

  def next
    return nil unless show

    show.episodes.find_by(['episodes.number > ?', number])
  end

  def views_count
    0
  end
end
