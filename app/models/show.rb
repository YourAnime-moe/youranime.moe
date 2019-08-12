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
      ShowsQueueRelation.where(show_id: id)
    end
  end

  def self.seed_from(csv_data, options: {})
    require 'csv'

    csv = csv_data if csv_data.class == CSV
    unless csv
      options[:headers] ||= true
      options[:header_converters] ||= :symbol
      options[:converters] ||= :all

      csv = CSV.new(csv_data, **options)
    end

    data = csv.to_a.map {|row| row.to_hash }
    data.each do |entry|
      episodes_count = entry[:episodes]
      released_on = nil
      begin
        released_on = JSON.parse(entry[:aired].gsub('\'', '"'))["from"]
      rescue => exception
        released_on = Time.now.utc
      end

      params = ActionController::Parameters.new(entry).permit(
        :en_title,
        :jp_title,
        :roman_title,
        :banner_url
      )
      params[:released_on] = released_on
      params[:plot] = 'anime.plot.coming_soon'
       
      Show.create(params)
    end
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
