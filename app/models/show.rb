# frozen_string_literal: true
require_relative 'active_storage'

class Show < ApplicationRecord
  include ShowScopesConcern
  include LikeableConcern
  include TanoshimuUtils::Concerns::RespondToTypes
  include TanoshimuUtils::Concerns::ResourceFetch
  include TanoshimuUtils::Concerns::HasTranslatableField
  include TanoshimuUtils::Validators::PresenceOneOf

  EMBED_YOUTUBE_BASE_URL = "https://www.youtube.com/embed"

  self.per_page = 48

  ANIME = 'anime'
  MOVIE = 'movie'

  SHOW_TYPES = [ANIME, MOVIE]
  AIRING_STATUSES = %w(current)
  FINISHED_STATUES = %w(finished)
  COMING_SOON_STATUSES = %w(coming_soon upcoming unreleased)

  SHOW_STATUSES = AIRING_STATUSES + FINISHED_STATUES + COMING_SOON_STATUSES

  DEFAULT_BANNER_URL = '/img/404.jpg'
  DEFAULT_POSTER_URL = '/img/404.jpg'

  before_validation :init_values
  can_be_liked_as :show

  # has_and_belongs_to_many :starring, class_name: 'Actor'
  has_many :shows_tag_relations
  has_many :tags, -> { distinct }, through: :shows_tag_relations

  has_many :ratings
  has_many :seasons, inverse_of: :show, class_name: 'Shows::Season'
  has_many :episodes, through: :seasons
  has_many :published_episodes, through: :seasons
  has_many :shows_queue_relations, inverse_of: :show
  has_many :queues, through: :shows_queue_relations
  has_many :urls, -> { ordered }, class_name: 'ShowUrl', inverse_of: :show, dependent: :destroy
  has_many :links, -> { ordered.streamable.non_watchable }, class_name: 'ShowUrl'
  has_many :info_links, -> { info }, class_name: 'ShowUrl'
  has_many :external_relationships, class_name: 'ShowExternalRelationship', dependent: :destroy

  has_one :title_record, -> {
                           with_slug
                         }, class_name: 'Title', foreign_key: :model_id, required: true, dependent: :destroy
  has_one :description_record, class_name: 'Description', foreign_key: :model_id, required: true, dependent: :destroy
  has_translatable_field :title
  has_translatable_field :description

  has_one_attached :banner
  has_one_attached :poster
  has_resource :banner, default_url: DEFAULT_BANNER_URL, expiry: 3.days
  has_resource :poster, default_url: DEFAULT_POSTER_URL, expiry: 3.days

  respond_to_types SHOW_TYPES

  validates_presence_of :released_on, :banner_url
  validates_inclusion_of :top_entry, :published, in: [true, false]
  # validates_inclusion_of :show_type, in: SHOW_TYPES

  scope :published, -> { includes(:seasons).where(published: true) }
  scope :recent, -> { published.order('shows.created_at desc') }
  scope :airing, -> { trending.where(status: AIRING_STATUSES) }
  scope :coming_soon, -> { trending.where(status: COMING_SOON_STATUSES) }
  scope :active, -> { trending.where(status: COMING_SOON_STATUSES + AIRING_STATUSES) }
  scope :this_year, -> { where("starts_on >= '#{Date.new(Time.current.year)}'") }
  scope :trending, -> { published.order(:popularity).where('popularity > 0') }
  scope :highly_rated, -> { published.includes(:ratings) }
  scope :ordered, -> { published.with_title.order("titles.#{I18n.locale}") }
  scope :as_music, -> { ordered.where(show_category: :music) }
  scope :streamable_on, -> (platform) do
    optimized.joins(:links)
      .where('show_urls.url_type' => sanitize_sql(platform))
  end
  scope :actively_streamable_on, -> (platform) { streamable_on(platform).active.this_year }
  scope :tv, -> { where(show_category: 'TV') }
  scope :random, -> { order('random()') }

  scope :optimized, -> do
    includes(:tags,
      :title_record,
      :description_record,
      :links,
      :urls,
      :queues,
      shows_queue_relations: :queue)
  end
  scope :published_with_title, -> { with_title.published }
  scope :with_title, -> { joins(:title_record).optimized }
  scope :searchable, -> { joins(:title_record).optimized }
  scope :with_links, -> { joins(:links).group(:id).having('count(*) > 0').order(:status).trending }

  # scope :missing_banner, -> { where(banner_url: DEFAULT_BANNER_URL) }
  # scope :missing_poster, -> { where(poster_url: DEFAULT_POSTER_URL) }
  scope :needing_update, -> { where.not(status: FINISHED_STATUES) }

  def publish
    update!(published: true)
  end

  def unpublish
    update!(published: false)
  end

  def publish_episodes
    episodes.update_all(published: true)
  end

  def unpublish_episodes
    episodes.update_all(published: false)
  end

  def synchable?
    reference_id.present? && reference_source.present?
  end

  def synched?
    synchable? && synched_at?
  end

  def kitsu?
    reference_source == 'kitsu'
  end

  def synched_by_user
    return unless synched?

    Users::Admin.find_by(id: synched_by)
  end

  def weighted_rating(minimum_score_count = 25)
    ratings_count = ratings.count.to_f
    return 0 if ratings_count < minimum_score_count

    global_rating = Rating.global

    (rating * ratings_count + global_rating * minimum_score_count) / \
      (ratings_count + minimum_score_count)
  end

  def rating
    average_rating = ratings.average(:value)
    return 'N/A' if average_rating.nil? || average_rating.zero?

    '%.2f' % average_rating
  end

  def views_count
    0
  end

  def duration
    duration = episodes.pluck(:duration).first
    return if duration.blank? || duration.zero?

    duration
  end

  def is?(show_type)
    self[:show_type] == show_type.to_s || self[:show_category] == show_type.to_s
  end

  def airing?
    AIRING_STATUSES.include?(status)
  end

  def coming_soon?
    COMING_SOON_STATUSES.include?(status)
  end

  def air_complete?
    FINISHED_STATUES.include?(status)
  end

  def general_status
    return :airing if airing?
    return :coming_soon if coming_soon?
    return :air_complete if air_complete?

    :unknown
  end

  def no_air_status?
    status.blank? || (!airing? && !coming_soon? && !air_complete? && airing_status == 'unknown')
  end

  def has_videos?
    has_trailer?
  end

  def has_trailer?
    youtube_trailer_url.present?
  end

  def youtube_trailer_url
    youtube_trailer_id.presence && "#{EMBED_YOUTUBE_BASE_URL}/#{youtube_trailer_id}"
  end

  def watchable?
    urls.watchable.any?
  end

  def has_links?
    links.any?
  end

  def slug
    title_record&.roman
  end

  def to_param
    slug
  end

  def anilist_id
    external_relationships.find_by(reference_source: 'anilist/anime')&.reference_id
  end

  def needs_update?
    (persisted? && !valid?) ||
      (airing? && external_relationships.empty?) ||
      coming_soon? ||
      no_air_status? ||
      urls.empty? ||
      # tags.empty? ||
      nsfw? ||
      !banner.attached? ||
      !poster.attached?
  end

  def related_shows
    related_show_ids = urls.map do |show_url|
      ShowUrl.select(:show_id).where(value: show_url.value).where.not(show_id: id)
    end.compact.flatten.map(&:show_id).uniq

    Show.where(id: related_show_ids)
  end

  def platforms(focus_on: nil)
    scope = Platform.where(name: urls.pluck(:url_type))
    return scope unless focus_on

    focus_platform = Platform.find_by(name: focus_on.to_s)
    return scope unless focus_platform.present?

    [focus_platform, scope.where.not(name: focus_on.to_s)].flatten
  end

  def self.search(by_title)
    by_title = "%#{by_title}%"

    Show.published_with_title.where('lower(titles.en) LIKE ?', by_title)
      .or(Show.published_with_title.where('lower(titles.jp) LIKE ?', by_title))
      .or(Show.published_with_title.where('lower(titles.roman) LIKE ?', by_title))
  end

  def self.search_all(by_title)
    by_title = "%#{by_title}%"

    Show.with_title.where('lower(titles.en) LIKE ?', by_title)
      .or(Show.with_title.where('lower(titles.jp) LIKE ?', by_title))
  end

  def self.find_by_slug(slug)
    find_by_slug!(slug)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.find_by_slug!(slug)
    Show
      .optimized
      .joins(:title_record)
      .find_by!('titles.roman' => slug)
  end

  def self.find_kitsu!(reference_id)
    find_by!(reference_id: reference_id, reference_source: 'kitsu')
  end

  def self.find_kitsu(reference_id)
    find_kitsu!(reference_id)
  rescue
    nil
  end

  def self.find_slug(slug, reference_source: nil)
    options = { 'titles.roman' => slug, :reference_source => reference_source }.compact

    with_title.find_by(options)
  end

  private

  def init_values
    return if persisted?

    self.released_on = Time.now.utc
  end
end
