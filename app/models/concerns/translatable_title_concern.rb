# frozen_string_literal: true

module TranslatableTitleConcern
  extend ActiveSupport::Concern

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
    result.presence || I18n.t('anime.shows.no-description')
  end
end
