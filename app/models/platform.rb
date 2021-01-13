# frozen_string_literal: true

class Platform < FrozenRecord::Base
  def detect_from
    self[:detect_from].map { |pattern| Regexp.new(pattern) }
  end

  def title
    I18n.t("anime.platforms.#{name}")
  end

  def active_shows
    Show.actively_streamable_on(name)
  end

  def shows
    Show.streamable_on(name)
  end

  def all_shows
    ids = (active_shows.ids + shows.ids).uniq
    Show.where(id: ids).order('starts_on DESC')
  end
end
