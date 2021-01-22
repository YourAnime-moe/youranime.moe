# frozen_string_literal: true

module HasPlatformConcern
  extend ActiveSupport::Concern

  class_methods do
    def has_platform(name, colour:, detect_from: nil, img: nil, info_url: nil, streamable: true, watchable: false)
      @@platforms_info ||= {}
      @@watchable_url_types ||= []
      @@streamable_url_types ||= []

      name = name.to_sym
      @@watchable_url_types << name if watchable
      @@streamable_url_types << name if streamable

      @@platforms_info[name] = {
        name: name,
        colour: colour,
        detect_from: (detect_from.is_a?(Array) ? detect_from : [detect_from]),
        img: img,
        info_url: info_url,
        info: false,
        watchable: watchable,
        streamable: streamable,
      }

      @@watchable_url_types.uniq!
      @@streamable_url_types.uniq!
    end

    def has_info_link(name, colour:, detect_from: nil)
      @@platforms_info ||= {}
      @@info_url_types ||= []

      name = name.to_sym
      @@info_url_types << name.to_sym

      @@platforms_info[name] = {
        name: name,
        colour: colour,
        detect_from: detect_from,
        info: true,
      }

      @@info_url_types.uniq!
    end

    def colour_for(platform)
      return unless @@platforms_info.present?

      @@platforms_info.dig(platform.to_sym, :colour)
    end

    def img_asset_filename_for(platform)
      return unless @@platforms_info.present?

      @@platforms_info.dig(platform.to_sym, :img)
    end

    def icon_asset_filename_for(platform, ext:)
      filename = img_asset_filename_for(platform)
      return unless filename.present?

      parts = filename.split('.')
      [[parts[0], '-icon'].join(''), ext].join('.')
    end

    def info_url_types
      @@info_url_types
    end

    def streamable_url_types
      @@streamable_url_types
    end

    def watchable_url_types
      @@watchable_url_types
    end
  end

  def info?
    @@info_url_types.include?(url_type.to_sym)
  end

  def streamable?
    @@streamable_url_types.include?(url_type.to_sym)
  end

  def watchable?
    @@watchable_url_types.include?(url_type.to_sym)
  end

  def img_asset_filename
    (streamable? && info_for(:img, default: 'unknown.png')).presence
  end

  def info_url
    (streamable? && info_for(:info_url)).presence
  end

  def platform
    Platform.find_by(name: url_type)
  end

  def colour
    info_for(:colour, default: '#aaaaaa')
  end
  alias_method :color, :colour

  def platform_info
    if unknown?
      {
        name: :unknown,
        colour: '#aaaaaa',
        info: false,
      }
    else
      @@platforms_info[url_type.to_sym]
    end
  end

  def unknown?
    !info? && !streamable? && !watchable? && platform == :unknown
  end

  private

  def info_for(key, if: nil, default: nil)
    return default unless @@platforms_info.present?

    condition = binding.local_variable_get(:if) || -> (info) { has_domain?(*info[:detect_from]) }

    @@platforms_info.each do |name, info|
      return info[key] if condition.call(info) || (url_type && Regexp.new(url_type) =~ name)
    end
    p('nothing')

    default
  end

  def has_domain?(*domains)
    domains.select do |domain|
      if domain.is_a?(Regexp)
        value =~ domain
      else
        value.include?(domain)
      end
    end.any?
  end
end
