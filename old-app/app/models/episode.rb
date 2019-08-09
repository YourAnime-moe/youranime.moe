# frozen_string_literal: true

class Episode < ApplicationRecord
  include ResourceFetchConcern

  has_one_attached :video
  has_one_attached :thumbnail
  has_resource :thumbnail, default_url: '/img/404.jpg', expiry: 3.days
  has_resource :video, default_url: '/img/404.mp4', expiry: 500.minutes

  belongs_to :show
  has_one :user_watch_progress, dependent: :destroy
  has_many :views, class_name: 'UserWatchProgress', dependent: :destroy
  has_many :subtitles, dependent: :destroy

  paginates_per 20

  validates :episode_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  scope :published, -> { joins(:show).where("shows.published = 't'") }

  def title
    return self['title'] if self['title'].present?

    "Episode #{episode_number}"
  end

  def published?
    (published && show&.published?).present?
  end

  def unrestricted?
    episodes = show&.episodes
    !episodes.nil? && episodes[0..2].include?(self)
  end

  def restricted?
    !unrestricted?
  end

  def subtitles?
    !subtitles.select { |subtitle| subtitle.src.attached? }.empty?
  end

  def next
    return nil unless show

    show.episodes.find_by(['episode_number > ?', episode_number])
  end

  def generate_urls!(force: false)
    return true if thumbnail_url? && !force

    new_url = thumbnail_url!
    new_url.present? && update(thumbnail_url: new_url)
  end

  def set_progress(current_user, progress)
    return false unless video.attached?

    user_progress = progress(current_user)
    if user_progress.persisted?
      res = user_progress.update(progress: progress)
    else
      user_progress.progress = progress
      res = user_progress.save
    end
    res
  end

  def progress(current_user)
    UserWatchProgress.find_by(episode_id: id, user_id: current_user.id) || UserWatchProgress.new(progress: 0)
  end

  def as_json(_ = {})
    {
      id: id,
      title: title,
      published: published?,
      show_id: show_id,
      thumbnail_url: thumbnail_url,
      video: video_url
    }
  end

  def self.remove_all_media
    all.each do |episode|
      Rails.logger.info "Cleaning thumbnail for episode id #{episode.id}"
      episode.thumbnail.purge if episode.thumbnail.attached?
      Rails.logger.info "Cleaning video for episode id #{episode.id}"
      episode.video.purge if episode.video.attached?
    end
  end

  def path
    self[:path] || "/videos/#{show.roman_title}/ep#{episode_number}"
  end
end
