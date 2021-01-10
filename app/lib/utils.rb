# frozen_string_literal: true
require 'i18n'

class Utils
  def self.tags
    I18n.t('tags')[:tags]
  end

  def self.valid_tags
    valid_sym = tags.keys
    valid_string = valid_sym.map(&:to_s)
    valid_sym + valid_string
  end

  def self.text_color(from:)
    data = from.match(/([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})/)
    return unless data.size >= 4

    r, g, b = [data[1], data[2], data[3]].map(&:hex)
    brigthness = ((r * 299) + (g * 587) + (b * 114)) / 1000

    brigthness > 125 ? '#000' : '#fff'
  end

  def self.weekday_for(date)
    case date.wday
    when 0
      'sunday'
    when 1
      'monday'
    when 2
      'tuesday'
    when 3
      'wednesday'
    when 4
      'thursday'
    when 5
      'friday'
    when 6
      'saturday'
    end
  end
end
