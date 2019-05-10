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
  scope :recent, -> {
    sql = <<-SQL
      select distinct shows.* from shows
      inner join episodes
      on shows.id = episodes.show_id
      where shows.published = 't'
      order by episodes.created_at desc;
    SQL
    find_by_sql(sql)
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
    result || I18n.t('anime.shows.no-description')
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

  def has_tags?(tags=nil)
    return get_tags.size > 0 if tags.nil?
    return false if tags.class != Array
    return false if tags.empty?
    tags.each do |tag|
      return false unless get_tags.include? tag
    end
    true
  end

  def add_tag(tag)
    return nil if tag.to_s.strip.empty?
    tag = tag.strip if tag.class == String
    self.tags = [] if self.tags.nil?
    return false unless Utils.tags.keys.include? tag
    self.tags.push tag unless self.tags.include? tag
    self.tags
  end

  def has_starring_info?
    self.starring.to_s.strip.size > 0
  end

  def discloses_average_run_time?
    !self.average_run_time.nil?
  end

  def is_published?
    !!self.published
  end

  def get_image_path(token=nil, as_is: false)
    return self.image_path if self.image_path.to_s.strip.empty? or self.image_path.start_with? "http"
    path = Config.path self.image_path, as_is: as_is
    return path if token == nil
    path + "?token=" + token
  end

  def get_new_image_path(as_is: false)
    return nil if self.image_path.nil?

    filename = self.image_path.split('/')
    under = filename[filename.size-2]
    filename = filename[filename.size-1]

    filename_parts = filename.split '.'
    extension = filename_parts[filename_parts.size-1]
    filename_name = filename_parts[0]

    Config.path "videos?show_icon=#{filename_name}&format=#{extension}&under=#{under}", as_is: as_is
  end

  def is_featured?
    return false if self.featured.nil?
    self.featured
  end

  def is_recommended?
    return false if self.recommended.nil?
    self.recommended
  end

  def get_season_code
    return 0 if self.season_code.nil?
    self.season_code
  end

  def get_season_year
    return self.get_year if self.season_year.nil?
    self.season_year
  end

  def is_this_season?
    self.is_from_season? Utils.current_season, Time.now.year
  end

  def is_from_season?(season_id, year)
    get_season_code == season_id && get_season_year == year
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

  def self.get_presence(tag, request_banner=true, limit=3, options: nil)
    found_shows = []
    self.all.each do |show|
      if options.class != Hash && tag == :season
        raise "Invalid season options"
      end
      next unless show.is_published?
      #next unless request_banner && show.has_banner?

      break if found_shows.size >= limit
      if tag == :recommended
        found_shows.push(show) if show.is_recommended?
      elsif tag == :featured
        found_shows.push(show) if show.is_featured?
      elsif tag == :season
        found_shows.push(show) if options[:current] == true && show.is_this_season?
      end
    end
    found_shows
  end

  def self.search keyword, preset_list=nil
    keyword = keyword.to_s.downcase
    preset_list = self.published if preset_list.class != Array
    preset_list.select do |show|
      show.get_title.downcase.include?(keyword) || show.title.downcase.include?(keyword)
    end
  end

  def self.get_random_shows(ids: true, has_banner: false, published: true, limit: 10)
    shows = self.all
    unless published == :all
      shows = shows.select{|show| show.is_published? == published}
    end
    shows = shows.select{|show| show.has_banner?} if has_banner
    shows = shows.map{|show| show.id} if ids
    shows = shows.shuffle
    if limit && limit > 0
      shows = shows[0..limit-1]
    end
    shows
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
