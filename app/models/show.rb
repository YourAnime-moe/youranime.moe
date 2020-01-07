require_relative 'active_storage'

class Show < ApplicationRecord
  include ShowScopesConcern
  include TanoshimuUtils::Concerns::RespondToTypes
  include TanoshimuUtils::Concerns::ResourceFetch
  include TanoshimuUtils::Validators::PresenceOneOf

  self.per_page = 24

  ANIME = 'anime'
  MOVIE = 'movie'

  SHOW_TYPES = [ANIME, MOVIE]

  before_validation :init_values

  has_and_belongs_to_many :starring, class_name: 'Actor'
  has_many :shows_tag_relations
  has_many :tags, -> { distinct }, through: :shows_tag_relations

  has_many :ratings
  has_many :seasons, inverse_of: :show, class_name: 'Shows::Season'
  has_many :episodes, through: :seasons
  has_many :shows_queue_relations
  has_many :queues, through: :shows_queue_relations
  has_one :title_record, class_name: 'Title', foreign_key: :model_id, required: true
  has_one :description_record, class_name: 'Description', foreign_key: :model_id, required: true

  has_one_attached :banner
  has_resource :banner, default_url: '/img/404.jpg', expiry: 3.days

  respond_to_types SHOW_TYPES

  validate :dub_sub

  validates_presence_of :released_on, :banner_url
  validates_inclusion_of :recommended, :published, :featured, in: [true, false]
  validates_inclusion_of :show_type, in: SHOW_TYPES

  def published?
    self[:published] || published_on? && published_on <= Time.now.utc
  end

  def title
    (@title ||= title_record).value
  end

  def title=(new_title_record)
    return unless new_title_record.kind_of?(Title)

    new_title_record.used_by_model = self.class.table_name
    new_title_record.model_id = self.id
    self.title_record = new_title_record
  end

  def description
    (@description ||= description_record).value
  end

  def description=(new_description_record)
    return unless new_description_record.kind_of?(Description)

    new_description_record.used_by_model = self.class.table_name
    new_description_record.model_id = self.id
    self.description_record = new_description_record
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

  def weighted_rating(minimum_score_count=25)
    ratings_count = ratings.count.to_f
    return 0 if ratings_count < minimum_score_count

    global_rating = Rating.global

    (rating * ratings_count + global_rating * minimum_score_count) / \
      (ratings_count + minimum_score_count)
  end

  def rating
    ratings.average(:value).to_f
  end

  def self.search(by_title)
    Title.search(by_title).map(&:record)
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
