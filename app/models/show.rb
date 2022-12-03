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
  COMING_SOON_STATUSES = %w(coming_soon upcoming unreleased tba)

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
  has_many :links, -> { ordered.streamable }, class_name: 'ShowUrl'
  has_many :other_links, -> { non_watchable }, class_name: 'ShowUrl'
  has_many :info_links, -> { info }, class_name: 'ShowUrl'
  has_many :external_relationships, class_name: 'ShowExternalRelationship', dependent: :destroy

  has_one :description_record, class_name: 'Description', foreign_key: :model_id, required: true, dependent: :destroy
  has_one :next_airing_info
  has_translatable_field :description

  has_one_attached :banner
  has_one_attached :poster
  has_resource :banner, default_url: DEFAULT_BANNER_URL, expiry: 3.days
  has_resource :poster, default_url: DEFAULT_POSTER_URL, expiry: 3.days

  has_one :poster_record, class_name: 'Poster'

  respond_to_types SHOW_TYPES

  validates_presence_of :released_on, :banner_url, :titles, :slug
  validates_inclusion_of :top_entry, :published, in: [true, false]
  # validates_inclusion_of :show_type, in: SHOW_TYPES

  scope :published, -> { includes(:seasons).where(published: true) }
  scope :recent, -> { published.order('shows.created_at desc') }
  scope :airing, -> { trending.where(status: AIRING_STATUSES) }
  scope :coming_soon, -> { where(status: COMING_SOON_STATUSES).order(:starts_on) }
  scope :active, -> { trending.where(status: COMING_SOON_STATUSES + AIRING_STATUSES) }
  scope :finished, -> { trending.where(status: FINISHED_STATUES) }
  scope :this_year, -> { where("starts_on >= '#{Date.new(Time.current.year)}'") }
  scope :trending, -> { published.order(:popularity).where('popularity > 0') }
  scope :highly_rated, -> { published.includes(:ratings) }
  scope :ordered, -> { published.with_title.order("titles.#{I18n.locale}") }
  scope :as_music, -> { where(show_category: :music) }
  scope :streamable_on, -> (platforms) do
    # optimized.joins(:links).
    platforms = Array(platforms) unless platforms.is_a?(Array)

    search_by_platforms = platforms.map do |platform|
      if platform.is_a?(Platform)
        platform
      else
        Platform.find_by(name: platform.to_s) || Platform.from(platform.to_s)
      end
    end.compact
    optimized.joins(:links).where(['show_urls.url_type in (?)', search_by_platforms.map(&:name)])
  end
  scope :streamable, -> {
                       joins(:urls).where('show_urls.url_type' => Platform.pluck(:name))
                     }
  scope :actively_streamable_on, -> (platform) { streamable_on(platform).active.this_year }
  scope :tv, -> { where(show_category: 'TV') }
  scope :random, -> { order('random()') }
  scope :new_this_season, -> do
    from, til = Config.season_date_range(Time.current)
    where("starts_on >= '#{from}' AND starts_on <= '#{til}'")
  end
  scope :from_last_season, -> do
    # Each season is every 3 months. So last season is guarenteed to
    # be at most 3 months ago.
    from, til = Config.season_date_range(3.months.ago)
    where("starts_on >= '#{from}' AND starts_on <= '#{til}'")
  end

  scope :optimized, -> do
    includes(:tags,
      :description_record,
      :links,
      :urls,
      :queues,
      shows_queue_relations: :queue)
  end
  scope :published_with_title, -> { with_title.published }
  scope :with_title, -> { optimized }
  scope :searchable, -> { optimized }
  scope :with_links, -> { joins(:links).group(:id).having('count(*) > 0').order(:status).trending }
  scope :with_next_airing_info, -> do
    joins(:next_airing_info)
      .order(:airing_at)
      .group(:id, :airing_at)
      .having('count(*) > 0')
  end

  # scope :missing_banner, -> { where(banner_url: DEFAULT_BANNER_URL) }
  # scope :missing_poster, -> { where(poster_url: DEFAULT_POSTER_URL) }
  scope :needing_update, -> { where.not(status: FINISHED_STATUES) }

  delegate :year, to: :starts_on, allow_nil: true
  delegate :airing_at, :next_episode, to: :next_airing_info, allow_nil: true

  def title
    current_locale = I18n.locale.to_sym
    available_locales = titles.keys
    selected_title_options = available_locales.select do |locale|
      locale =~ Regexp.new(current_locale.to_s) && titles[locale].present?
    end
    return unless selected_title_options.any?

    titles[selected_title_options.first]
  end

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

    format('%.2f', average_rating)
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

  def official_url
    urls.find_by(url_type: :official)&.value
  end

  def watchable?
    urls.watchable.any?
  end

  def has_links?
    links.any?
  end

  def to_param
    slug
  end

  def anilist_id
    external_relationships.find_by(reference_source: 'anilist/anime')&.reference_id
  end

  def mal_id
    external_relationships.find_by(reference_source: 'myanimelist/anime')&.reference_id
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
      !poster.attached? ||
      poster_record.nil? ||
      poster_record&.missing? ||
      titles.empty? ||
      slug.blank?
  end

  def related_shows
    cleaned_urls = urls.select do |url|
      url.platform ? URI.parse(url.platform.url) != URI.parse(url.value) : true
    end

    Show.joins(:urls)
      .where(['show_urls.value in (?)', cleaned_urls.pluck(:value)])
      .where.not(id: id)
      .order(:starts_on)
      .reverse_order
      .distinct
  end

  def platforms(for_country: nil, focus_on: nil)
    scope = Platform.detect_from(urls).for_country(for_country)
    return scope unless focus_on

    focus_platform = scope.find_by(name: focus_on.to_s)
    return scope unless focus_platform.present?

    [focus_platform, scope.where.not(name: focus_on.to_s)].flatten
  end

  # To do: store in DB
  def popularity_percentage
    result = (1 - (relative_popularity.to_f / popularity_scope.count)) * 100
    [1, result.to_i].max
  end

  def relative_popularity
    popularity_scope.index(self) + 1
  end

  def poster_url?
    self[:poster_url].present? && poster.attached?
  end

  def banner_url?
    self[:banner_url].present? && banner.attached?
  end

  def update_banner_and_poster_urls!(**options)
    force = options[:force] || false
    return nil unless persisted?
    if !force
      return true if poster_url? && banner_url?
    end

    attributes = {
      poster_url: poster.url(expires_in: 3.days),
      banner_url: banner.url(expires_in: 3.days),
    }.compact

    attributes.present? ? update(attributes) : false
  end

  def self.exclusive_on(platform)
    # select * from shows inner join
    # (select count(su.url_type), shows.slug
    #   from shows inner join show_urls su on su.show_id = shows.id
    #   where su.url_type = 'funimation'
    #   group by shows.slug, su.url_type
    #   having count(*) = 1 order by count desc)
    # as exclusive_shows
    # on exclusive_shows.slug = shows.slug;

    Show.joins([
      'INNER JOIN',
      "(select count(su.url_type), shows.slug",
      "from shows inner join show_urls su on su.show_id = shows.id",
      "where su.url_type = '#{platform}'",
      "group by shows.slug, su.url_type",
      "having count(*) = 1 order by count desc) as exclusive_shows",
      'on exclusive_shows.slug = shows.slug',
    ].join(' '))
  end

  def self.search(by_title, limit: 20)
    by_title = "%#{by_title}%"

    searchable_shows = Show
      .distinct
      .select(:id)
      .from('(select id, svals(titles) as title, slug from shows) as shows_title')

    shows_by_title = searchable_shows.where('lower(title) LIKE ?', by_title)
    shows_by_slug = searchable_shows.where('lower(slug) LIKE ?', by_title)
    shows_by_title_no_special = searchable_shows.where(
      "lower(regexp_replace(title, '[^[:alnum:]]', '', 'g')) LIKE ?", by_title
    )
    shows_by_slug_no_special = searchable_shows.where(
      "lower(regexp_replace(slug, '[^[:alnum:]]', '', 'g')) LIKE ?", by_title
    )

    where(id:
      shows_by_title
        .or(shows_by_slug)
        .or(shows_by_title_no_special)
        .or(shows_by_slug_no_special).ids)
      .limit(limit)
  end

  def self.by_tags(*tags)
    return all if tags.empty?

    tags = tags.map do |tag|
      tag.is_a?(Tag) ? tag.value : tag.to_s
    end

    Show.joins(:tags)
      .where('tags.value in (?)', tags)
      .group('shows.id')
      .having('count(tags.*) = ?', tags.count)
  end

  def self.by_year(year)
    from = Date.new(year.to_i)
    til = Date.new(year.to_i + 1) - 1

    where("starts_on >= '#{from}' AND starts_on < '#{til}'")
  end

  def self.by_season(season:, year:)
    from, til = Config.dates_range_for_season(season: season, year: year)

    where("starts_on >= '#{from}' AND starts_on < '#{til}'")
  end

  def self.search_all(by_title)
    by_title = "%#{by_title}%"

    Show.with_title.where('lower(titles.en) LIKE ?', by_title)
      .or(Show.with_title.where('lower(titles.jp) LIKE ?', by_title))
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

  def self.sort_filters(*filters)
    scope = all
    filters.map do |filter|
      scope = if filter.use_scope
        scope = scope.send(filter.use_scope)
        scope = scope.reverse unless filter.ascending?
        scope
      else
        scope.order(filter.sql_friendly)
      end
    end
    scope
  end

  def self.filter(*scopes)
    scopes.inject(all) do |current_scope, new_scope|
      current_scope.send(new_scope)
    end
  end

  private

  def init_values
    return if persisted?

    self.released_on = Time.now.utc
  end

  def popularity_scope
    @popularity_scope ||= Show.where(show_category: show_category, status: status).order(:popularity)
  end
end
