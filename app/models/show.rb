require_relative 'active_storage'

class Show < ApplicationRecord
  include ConnectsToShowsConcern
  include RespondToTypesConcern
  include ValidatePresenceOneOfConcern

  ANIME = 'anime'
  MOVIE = 'movie'

  SHOW_TYPES = [ANIME, MOVIE]

  before_validation :init_values

  has_and_belongs_to_many :starring, class_name: 'Actor'
  has_and_belongs_to_many :tags

  has_many :ratings
  has_many :seasons, inverse_of: :show
  has_many :shows_queue_relations
  has_one_attached :banner

  respond_to_types SHOW_TYPES

  validate :dub_sub
  validate_presence_one_of [:en_title, :fr_title, :jp_title]
  validate_presence_one_of [:en_description, :fr_description, :jp_description]

  validates_presence_of :plot, :released_on, :banner_url, :roman_title
  validates_inclusion_of :recommended, :published, :featured, in: [true, false]
  validates_inclusion_of :show_type, in: SHOW_TYPES

  def queues
    ShowsQueueRelation.connected_to(role: :reading) do
      ids = ShowsQueueRelation.where(show_id: id).pluck(:queue_id)
      Shows::Queue.where(id: ids)
    end
  end

  def published?
    published_on? && published_on <= Time.now.utc
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
