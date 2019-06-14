# frozen_string_literal: true

class Show < ApplicationRecord
  include ResourceFetchConcern
  include ShowScopesConcern
  include TranslatableTitleConcern

  self.per_page = 24

  has_many :episodes, -> { published.order(:episode_number) }, inverse_of: :show
  has_many :all_episodes, -> { order(:episode_number) }, class_name: 'Episode', inverse_of: :show
  has_many :views, -> { where('progress > 0') }, through: :all_episodes, inverse_of: :show

  has_one_attached :banner
  has_resource :banner, default_url: 'https://anime.akinyele.ca/img/404.jpg', expiry: 3.days

  serialize :tags

  validate :title_present
  validate :description_present
  validates :roman_title, presence: true

  before_save do
    # Make the show is at least one of dubbed or subbed.
    self.subbed = true if dubbed.nil? && subbed.nil?
    show_number = 1 if show_number.nil?

    if !show_number.nil? && show_number < 1
      errors.add 'show_number', "can't be negative"
      throw :abort
    end
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

  def title(html: false, default: nil)
    if html
      return '<i>No title</i>'.html_safe if title(html: false, default: nil).blank?
    end
    (self[:title] || default || alternate_title)
  end

  def generate_urls!(force: false)
    return true if banner_url? && !force

    new_url = banner_url!
    new_url.present? && update(banner_url: new_url)
  end

  def tags
    return [] if self[:tags].nil?

    self[:tags].class == String ? self[:tags].split(' ') : self[:tags]
  end

  def add_tag(tag)
    return nil if tag.blank?

    tag = tag.strip if tag.class == String
    return false unless Utils.tags.keys.include? tag

    tags = [] if tags.nil?
    tags.push tag unless tags.include? tag
    tags
  end

  def as_json(_ = {})
    {
      id: id,
      title: title(default: '<No title>'),
      description: description,
      subbed: subbed,
      dubbed: dubbed,
      published: published?,
      tags: tags,
      episodes_count: {
        published: episodes.size,
        all: all_episodes.size
      },
      banner_url: banner_url
    }
  end

  def self.clean_up
    all.each do |show|
      p "Cleaning banner for show id #{show.id}"
      show.banner.purge if show.banner.attached?
      p "Making banner for show id #{show.id}"
      show.get_banner
    end
  end

  def self.remove_all_media
    all.each do |show|
      p "Cleaning banner for show id #{show.id}"
      show.banner.purge if show.banner.attached?
    end
  end

  private

  def title_present
    return unless en_title.blank? && jp_title.blank? && fr_title.blank?

    errors.add(:title, 'must be present')
  end

  def description_present
    if en_description.blank? && jp_description.blank? && fr_description.blank?
      errors.add(:description, 'must be present')
    end
  end

  def path
    "videos/images/#{roman_title}"
  end
end
