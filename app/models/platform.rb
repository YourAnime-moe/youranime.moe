# frozen_string_literal: true

class Platform < FrozenRecord::Base
  scope :ordered, -> { order(:name) }
  scope :global, -> { where(countries: nil) }
  scope :region_locked, -> { where.not(countries: nil) }
  scope :restricted, -> { where.not(blocked: nil) }

  def detect_from
    self[:detect_from].map { |pattern| Regexp.new(pattern) }
  end

  def title
    I18n.t("anime.platforms.#{name}")
  end

  def active_shows
    Show.actively_streamable_on(name)
  end

  def airing_now
    active_shows.airing
  end

  def coming_soon
    active_shows.coming_soon
  end

  def other_shows
    shows.finished
  end

  def shows
    Show.streamable_on(name)
  end

  def all_shows
    ids = (active_shows.ids + shows.ids).uniq
    Show.where(id: ids).order('starts_on DESC').optimized
  end

  def random_shows(limit: nil)
    ids = shows.limit(limit).ids.uniq.shuffle

    ids.map { |id| Show.find(id) }
  end

  def to_s
    name.to_s
  end

  def countries
    Array(self[:countries]) - Array(blocked)
  end

  def global?
    countries.blank?
  end

  def available?(country_iso_code)
    !Array(blocked).include?(country_iso_code) && (global? || countries.include?(country_iso_code))
  end

  def self.for_country(country_iso_code)
    return all if country_iso_code.blank?

    platforms = []
    all.each do |platform|
      platforms << platform if platform.available?(country_iso_code)
    end
    where(name: platforms.map(&:name))
  end

  def self.from(name)
    Platform.all.detect do |platform|
      platform.detect_from.detect do |regex|
        name =~ regex
      end
    end
  end

  def self.detect_from(urls_or_names)
    urls_or_names = Array(urls_or_names) unless urls_or_names.is_a?(Array)

    names = urls_or_names.map do |url_or_name|
      if url_or_name.is_a?(String) || url_or_name.is_a?(Symbol)
        next url_or_name.to_s
      end

      if url_or_name.is_a?(ShowUrl)
        next url_or_name.value
      end
    end.compact.map do |name|
      Platform.from(name)&.name
    end.compact

    where(name: names)
  end
end
