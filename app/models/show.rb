require_relative 'active_storage'

class Show < ApplicationRecord
  include ShowScopesConcern
  include LikeableConcern
  include TanoshimuUtils::Concerns::RespondToTypes
  include TanoshimuUtils::Concerns::ResourceFetch
  include TanoshimuUtils::Concerns::HasTranslatableField
  include TanoshimuUtils::Validators::PresenceOneOf

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

  has_one :title_record, class_name: 'Title', foreign_key: :model_id, required: true
  has_one :description_record, class_name: 'Description', foreign_key: :model_id, required: true
  has_translatable_field :title
  has_translatable_field :description

  has_one_attached :banner
  has_one_attached :poster
  has_resource :banner, default_url: '/img/404.jpg', expiry: 3.days
  has_resource :poster, default_url: '/img/404.jpg', expiry: 3.days

  respond_to_types SHOW_TYPES

  validate :dub_sub

  validates_presence_of :released_on, :banner_url
  validates_inclusion_of :recommended, :published, :featured, in: [true, false]
  #validates_inclusion_of :show_type, in: SHOW_TYPES

  scope :published, -> { includes(:seasons).where(published: true) }
  scope :recent, -> { published.order(:published_on).order('created_at desc') }
  scope :trending, -> { published.order(:popularity).where('popularity > 0') }
  scope :highly_rated, -> { published.includes(:ratings) }

  scope :optimized, -> { includes(:ratings, :tags, :title_record, :queues, shows_queue_relations: :queue, seasons: :episodes) }
  scope :published_with_title, -> { with_title.published }
  scope :with_title, -> { joins(:title_record).optimized }
  scope :searchable, -> { joins(:title_record).optimized }

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

  def only_subbed?
    (!subbed? && !dubbed?) || subbed? && !dubbed?
  end

  def only_dubbed?
    dubbed? && !subbed?
  end

  def subbed_and_dubbed?
    subbed? && dubbed?
  end

  def synchable?
    reference_id.present?
  end

  def synched?
    synchable? && synched_at?
  end

  def synched_by_user
    return unless synched?

    Staff.find_by(id: synched_by)
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

  def is?(show_type)
    self[:show_type] == show_type.to_s
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

  def dub_sub
    if dubbed.nil? && subbed.nil?
      errors.add(:subbed, 'must at least be selected')
    end
  end
end
