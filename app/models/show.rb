class Show < ActiveRecord::Base

  has_one_attached :banner
  serialize :tags

  include Navigatable

  scope :valid, -> {
    title_query = "(title is not null and title != '')"
    atitle_query = "(alternate_title is not null and alternate_title != '')"

    where("#{title_query} and #{atitle_query}")
  }
  scope :published, -> { valid.where(published: true) }
  scope :by_season, -> (title) { published.where(title: title).order(:show_number) }

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

  def dub_sub_info
    return "Dubbed and Subbed" if self.dubbed and self.subbed;
    return "Dubbed" if self.dubbed
    "Subbed"
  end

  def only_subbed?
    !!subbed && !dubbed
  end

  def only_dubbed?
    !!dubbed && !subbed
  end

  def get_title(html: false, default: nil)
    if html
      return "<i>No title</i>".html_safe if self.get_title(html: false, default: nil).blank?
    end
    (title || default || alternate_title)
  end

  def title
    result = self['title'] if I18n.locale == :en
    result = self['fr_title'] if I18n.locale == :fr
    result = self['jp_title'] if I18n.locale == :jp
    return self['title'] if result.nil?
    result
  end

  def description
    result = self['description'] if I18n.locale == :en
    result = self['fr_description'] if I18n.locale == :fr
    result = self['jp_description'] if I18n.locale == :jp
    return self['description'] if result.blank?
    result
  end

  def prequel
    return nil if self.show_number.nil? || self.show_number < 1
    Show.all.select { |e| e.title == self.title }.each do |show|
      return show if show.show_number == self.show_number - 1
    end
    nil
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

  def sequel
    return nil if self.show_number.nil? || self.show_number < 1
    Show.all.select { |e| e.title == self.title }.each do |show|
      return show if show.show_number == self.show_number + 1
    end
    nil
  end

  def episodes(from: nil)
    return nil if self.id.nil?
    results = Show::Episode.published.where(show_id: self.id).order(:episode_number)
    return results if from.nil?

    if from.class == Show::Episode
      from = from.episode_number
    end

    results = []
    results.each do |episode|
      if episode.episode_number >= from
        results << episode
      end
    end
    results
  end

  def all_episodes
    Show::Episode.all.select{ |e| e.show_id == self.id}.sort_by(&:episode_number)
  end

  def split_episodes(sort_by: 4)
    episodes = self.episodes
    return nil if episodes.nil?
    episodes = episodes.to_a unless episodes.instance_of? Array
    episodes.each_slice(sort_by).to_a
  end

  def get_tags
    if self.tags.nil?
      self.tags = []
      self.save
    end
    self.tags
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
    return false if self.published.nil?
    self.published
  end

  def is_coming_soon?
    !self.publish_after.nil? && !self.is_published? && self.publish_after > Date.new
  end

  def has_episodes?
    !self.episodes.empty?
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

  def has_image?
    self.image_path.to_s.strip.size > 0
  end

  def has_description?
    self.description.to_s.strip.size > 0
  end

  def is_featured?
    return false if self.featured.nil?
    self.featured
  end

  def is_recommended?
    return false if self.recommended.nil?
    self.recommended
  end

  def is_new_addition?

  end

  def is_anime?
    self.show_type.to_s.size == 0 || self.show_type == 0
  end

  def is_drama?
    self.show_type == 1
  end

  def is_movie?
    self.show_type == 2
  end

  def is_new?
    self.id.nil?
  end

  def get_year
    return 0.years.ago.year if self.is_new?
    self.year
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

  def get_description(limit=50)
    return nil unless self.has_description?
    return self.description if limit.nil?
    if limit > self.description.size
      limit = self.description.size
    end
    self.description[0, limit] + "..."
  end

  def admin_json
    {
      title: title,
      alternate_title: alternate_title,
      get_title: get_title(default: "<No title>"),
      description: description,
      subbed: subbed,
      dubbed: dubbed,
      published: is_published?,
      banner_url: get_banner_url,
      image_path: image_path,
      default_path: default_path,
      id: id
    }
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

  def publish_after
    nil
  end

  def self.get(title: nil, show_number: nil)
    return nil if title.nil? || show_number.nil?
    title = title.capitalize
    self.find_by(title: title, show_number: show_number)
  end

  def self.instances
    [:get_title]
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

  def self.lastest(current_user, limit: 5)
    self.latest current_user, limit: limit
  end

  def self.latest(current_user, limit: 5)
    episodes = current_user.get_episodes_watched
    episodes = episodes.map{|e| Show::Episode.find e}.reverse
    shows = []
    episodes.each do |ep|
      next unless ep.is_published?
      show = ep.show
      next unless show.is_published?
      next unless show.has_image?
      shows.push show unless shows.include? show
      break if shows.size >= limit
    end
    shows
  end

  def self.coming_soon limit: nil
    shows = Show.all.select {|show| show.is_coming_soon?}
    return shows if limit.nil? || limit < 1
    shows[0...limit]
  end

  def self.all_published
    self.all.select{|e| !e.get_title.nil? && e.is_published?}.to_a.sort_by(&:get_title)
  end

  def self.all_un_published
    self.all.reject{|e| e.get_title.nil? || e.is_published?}.to_a.sort_by(&:get_title)
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

end
