# frozen_string_literal: true

class Episode < ApplicationRecord
  has_one_attached :video
  has_one_attached :thumbnail
  has_one :user_watch_progress
  has_many :views, class_name: 'UserWatchProgress'
  has_many :subtitles
  belongs_to :show
  serialize :comments
  paginates_per 20
  validates :episode_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  scope :published, -> { joins(:show).where("shows.published = 't'") }

  def get_title
    return title if title.present?

    "Episode #{episode_number}"
  end

  def is_published?
    !!(published && show&.is_published?)
  end

  def unrestricted?
    !!show&.episodes[0..2].include?(self)
  end

  def restricted?
    !unrestricted?
  end

  def has_subtitles?
    !subtitles.select { |subtitle| subtitle.src.attached? }.empty?
  end

  def next
    return nil unless show

    show.episodes.where(['episode_number > ?', episode_number]).first
  end

  def get_thumbnail(raise_exception: false)
    unless thumbnail.attached?
      begin
        path = "videos/#{show.roman_title}/ep#{episode_number}"
        return thumbnail if path.nil? || File.directory?(path)

        thumbnail.attach(io: File.open(path), filename: "episode-#{id}")
      rescue Errno::ENOENT => e
        Rails.logger.error "Oh no!! The episode thumbnail was not found! #{e}"
        raise e if raise_exception
      end
    end
    thumbnail
  end

  def get_thumbnail_url
    thumbnail = get_thumbnail
    return 'https://anime.akinyele.ca/img/404.jpg' unless thumbnail.attached?

    get_thumbnail.service_url(expires_in: 3.days)
  end

  def thumbnail_url
    return self['thumbnail_url'] if self['thumbnail_url']

    'https://anime.akinyele.ca/img/404.jpg'
  end

  def generate_urls!(force: false)
    return true if thumbnail_url? && !force

    update(thumbnail_url: get_thumbnail_url)
  end

  def has_video?
    !!(video&.attached?)
  end

  def get_video(raise_exception: false)
    unless video.attached?
      begin
        path = "videos/#{show.roman_title}/ep#{episode_number}"
        return video if path.nil? || File.directory?(path)

        video.attach(io: File.open(path), filename: "episode-#{id}")
      rescue Errno::ENOENT => e
        Rails.logger.error "Oh no!! The episode video was not found! #{e}"
        raise e if raise_exception
      end
    end
    video
  end

  def get_video_url(expires_in: 500.minutes)
    video = get_video
    return 'https://anime.akinyele.ca/img/404.mp4' unless video.attached?

    get_video.service_url(expires_in: expires_in)
  end

  def set_progress(current_user, progress)
    return false unless video.attached?

    user_progress = progress(current_user)
    if user_progress.persisted?
      user_progress.update(progress: progress)
    else
      user_progress.progress = progress
      user_progress.save
    end
  end

  def progress(current_user)
    UserWatchProgress.find_by(episode_id: id, user_id: current_user.id) || UserWatchProgress.new(progress: 0)
  end

  def as_json(options = {})
    options[:ignore_urls] = options[:ignore_urls].nil? || options[:ignore_urls]
    json = {
      id: id,
      title: get_title,
      published: is_published?,
      show_id: show_id
    }
    unless options[:ignore_urls]
      json.merge(
        thumbnail: get_thumbnail_url,
        video: get_video_url
      )
    end
    json
  end

  def self.clean_up
    all.each do |episode|
      p "Cleaning thumbnail for episode id #{episode.id}"
      episode.thumbnail.purge if episode.thumbnail.attached?
      p "Making thumbnail for episode id #{episode.id}"
      episode.get_thumbnail
      p "Cleaning video for episode id #{episode.id}"
      episode.video.purge if episode.video.attached?
      p "Making video for episode id #{episode.id}"
      episode.get_video
    end
  end

  def self.remove_all_media
    all.each do |episode|
      p "Cleaning thumbnail for episode id #{episode.id}"
      episode.thumbnail.purge if episode.thumbnail.attached?
      p "Cleaning video for episode id #{episode.id}"
      episode.video.purge if episode.video.attached?
    end
  end

  class DummyProgress
    def progress
      0
    end
  end
end
