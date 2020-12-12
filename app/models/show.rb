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

  before_validation :init_values
  can_be_liked_as :show

  has_and_belongs_to_many :starring, class_name: 'Actor'
  has_many :shows_tag_relations
  has_many :tags, -> { distinct }, through: :shows_tag_relations

  has_many :ratings
  has_many :seasons, inverse_of: :show, class_name: 'Shows::Season'
  has_many :episodes, through: :seasons
  has_many :published_episodes, through: :seasons
  has_many :shows_queue_relations, inverse_of: :show
  has_many :queues, through: :shows_queue_relations
  has_many :urls, class_name: 'ShowUrl', inverse_of: :show
  has_many :links, -> { non_watchable }, class_name: 'ShowUrl'

  has_one :title_record, class_name: 'Title', foreign_key: :model_id, required: true
  has_one :description_record, class_name: 'Description', foreign_key: :model_id, required: true
  has_translatable_field :title
  has_translatable_field :description

  has_one_attached :banner
  has_one_attached :poster
  has_resource :banner, default_url: '/img/404.jpg', expiry: 3.days
  has_resource :poster, default_url: '/img/404.jpg', expiry: 3.days

  respond_to_types SHOW_TYPES

  validates_presence_of :released_on, :banner_url
  validates_inclusion_of :top_entry, :published, in: [true, false]
  #validates_inclusion_of :show_type, in: SHOW_TYPES

  scope :published, -> { includes(:seasons).where(published: true) }
  scope :recent, -> { published.order('created_at desc') }
  scope :airing, -> { trending.where(airing_status: :airing) }
  scope :coming_soon, -> { trending.where(airing_status: :coming_soon) }
  scope :trending, -> { published.order(:popularity).where('popularity > 0') }
  scope :highly_rated, -> { published.includes(:ratings) }

  scope :optimized, -> { includes(:ratings, :tags, :title_record, :queues, shows_queue_relations: :queue, seasons: :episodes) }
  scope :published_with_title, -> { with_title.published }
  scope :with_title, -> { joins(:title_record).optimized }
  scope :searchable, -> { joins(:title_record).optimized }
  scope :with_links, -> { joins(:links).group(:id).having('count(*) > 0').order(:airing_status).trending }

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
    reference_id.present?
  end

  def synched?
    synchable? && synched_at?
  end

  def synched_by_user
    return unless synched?

    Users::Admin.find_by(id: synched_by)
  end

  def weighted_rating(minimum_score_count=25)
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
    self[:show_type] == show_type.to_s
  end

  def airing?
    status == 'current'
  end

  def coming_soon?
    status == 'planned'
  end

  def air_complete?
    status == 'completed' || status == 'finished'
  end

  def dropped?
    status == 'dropped'
  end

  def on_hold?
    status == 'on_hold'
  end

  def no_air_status?
    status.blank? || airing_status == 'unknown'
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
    return unless title.present?

    title_record.roman
  end

  def to_param
    slug
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
    Show
      .optimized
      .joins(:title_record)
      .where('titles.roman' => slug)
      .first
  end

  private

  def init_values
    return if persisted?

    self.released_on = Time.now.utc
  end
end
