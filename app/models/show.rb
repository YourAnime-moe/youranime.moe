class Show < ApplicationRecord

  include Navigatable

  self.per_page = 24

  has_many :episodes, -> { published.order(:episode_number) }
  has_many :all_episodes, -> { order(:episode_number) }, class_name: 'Episode'
  has_many :views, -> { where('progress > 0') }, through: :all_episodes
  has_one_attached :banner

  scope :by_season, -> (title) { published.where(title: title).order(:show_number) }
  scope :coming_soon, -> { where("publish_after is not null and publish_after > '#{Date.current}' ") }
  scope :published, -> { valid.where(published: true) }
  scope :recent, -> (limit: 50) {
    limit = 1 if limit < 1
    sql = <<-SQL
      select shows.* from shows
      inner join episodes
      on shows.id = episodes.show_id
      where shows.published = 't'
      order by episodes.created_at desc
      limit ?;
    SQL
    find_by_sql([sql, limit])
  }
  scope :latest, -> (current_user, limit: 5) {
    limit = 1 if limit < 1
    sql = <<-SQL
      select distinct shows.*
      from shows inner join (
        select ep.* from user_watch_progresses as up
        inner join episodes ep on up.episode_id = ep.id
        where up.user_id = ?
      ) as we on we.show_id = shows.id limit ?;
    SQL
    find_by_sql([sql, current_user.id, limit])
  }
  scope :trending, -> (limit: 6) {
    sql = <<-SQL
      select sum(views) as views, shows.*
      from (
        select episodes.show_id, count(*) as views
        from episodes
        inner join user_watch_progresses up
        on up.episode_id = episodes.id
        where progress > 0
        group by episodes.id
        having count(*) > 0
        order by views desc limit 100
      ) as sv
      inner join shows
      on show_id = shows.id
      group by shows.id
      order by views desc
      limit ?;
    SQL
    find_by_sql([sql, limit])
  }
  scope :valid, -> {
    roman_title_query = "(roman_title is not null and roman_title != '')"
    en_title_query = "(en_title is not null and en_title != '')"
    fr_title_query = "(fr_title is not null and fr_title != '')"
    jp_title_query = "(jp_title is not null and jp_title != '')"
    ordered.where("#{roman_title_query} and (#{en_title_query} or #{fr_title_query} or #{jp_title_query})")
  }
  scope :ordered, -> {
    title_column = nil
    case I18n.locale
    when :fr
      title_column = 'fr_title'
    when :jp
      title_column = 'jp_title'
    else
      title_column = 'en_title'
    end
    order(:alternate_title).order(:roman_title).order("#{title_column} asc")
  }
  scope :search, -> (query, limit: nil) {
    return published if query.empty?
    titles_to_search = [:en_title, :fr_title, :jp_title, :alternate_title, :roman_title]
    titles_as_queries = titles_to_search.map{ |key| "(lower(shows.#{key}) like '%%#{query}%%')" }.join(' or ')
    sql = <<-SQL
      select * from shows
      where (#{titles_as_queries})
      and shows.published = 't'
    SQL
    sql_args = [sql]
    sql_args << ("limit #{limit}") unless limit.to_i == 0
    find_by_sql(sql_args)
  }

  serialize :tags

  validate :title_present
  validate :description_present
  validates :roman_title, presence: true

  before_save {
    # Make the show is at least one of dubbed or subbed.
    if self.dubbed.nil? and self.subbed.nil?
      # Default to...
      self.subbed = true
    end

    if self.show_number.nil?
      self.show_number = 1
    end

    if !self.show_number.nil? && self.show_number < 1
      self.errors.add "show_number", "can't be negative"
      throw :abort
    end
  }

  def only_subbed?
    (!subbed && !dubbed) || !!subbed && !dubbed
  end

  def only_dubbed?
    !!dubbed && !subbed
  end

  def subbed_and_dubbed?
    !!subbed && !!dubbed
  end

  def get_title(html: false, default: nil)
    if html
      return "<i>No title</i>".html_safe if self.get_title(html: false, default: nil).blank?
    end
    (title || default || alternate_title)
  end

  def title
    return en_title if I18n.locale == :en || I18n.locale.nil?
    return fr_title if I18n.locale == :fr
    return jp_title if I18n.locale == :jp
    roman_title
  end

  def description
    result = self['en_description'] if I18n.locale == :en || I18n.locale.nil?
    result = self['fr_description'] if I18n.locale == :fr
    result = self['jp_description'] if I18n.locale == :jp
    result.blank? ? I18n.t('anime.shows.no-description') : result
  end

  def has_banner?
    get_banner(raise_exception: false).attached?
  end

  def get_banner(raise_exception: false)
    unless banner.attached?
      begin
        path = get_image_path(as_is: true)
        return banner if path.nil? || File.directory?(path)
        banner.attach(io: File.open(path), filename: Utils.get_filename(path))
      rescue Errno::ENOENT => e
        puts "Oh no!! The show banner was not found! #{e}"
        raise e if raise_exception
      end
    end
    banner
  end

  def get_banner_url
    banner = get_banner
    return "https://anime.akinyele.ca/img/404.jpg" unless banner.attached?
    get_banner.service_url
  end

  def get_tags
    if self.tags.nil?
      self.tags = []
      self.save
    end
    self.tags.class == String ? self.tags.split(' ') : self.tags
  end

  def add_tag(tag)
    return nil if tag.blank?
    tag = tag.strip if tag.class == String
    return false unless Utils.tags.keys.include? tag
    self.tags = [] if self.tags.nil?
    self.tags.push tag unless self.tags.include? tag
    self.tags
  end

  def is_published?
    !!self.published
  end

  def as_json(options={})
    {
      id: id,
      title: get_title(default: "<No title>"),
      description: description,
      subbed: subbed,
      dubbed: dubbed,
      published: is_published?,
      banner: get_banner_url,
      tags: get_tags,
      episodes_count: {
        published: episodes.size,
        all: all_episodes.size
      }
    }
  end

  def self.clean_up
    self.all.each do |show|
      p "Cleaning banner for show id #{show.id}"
      show.banner.purge if show.banner.attached?
      p "Making banner for show id #{show.id}"
      show.get_banner
    end
  end

  def self.remove_all_media
    self.all.each do |show|
      p "Cleaning banner for show id #{show.id}"
      show.banner.purge if show.banner.attached?
    end
  end

  private

  def title_present
    if en_title.blank? && jp_title.blank? && fr_title.blank?
      errors.add(:title, 'must be present')
    end
  end

  def description_present
    if en_description.blank? && jp_description.blank? && fr_description.blank?
      errors.add(:description, 'must be present')
    end
  end

end
