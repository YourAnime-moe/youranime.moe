# frozen_string_literal: true
class ShowUrl < ApplicationRecord
  belongs_to :show, inverse_of: :urls
  before_validation :ensure_url_type, unless: :url_type

  # has_info_link :official, colour: '#bbbbbb'
  # has_info_link :twitter, colour: '#1DA1F2', detect_from: 'twitter.com'

  scope :ordered, -> { order(:url_type) }
  scope :watchable, -> { where(url_type: []) }
  scope :non_watchable, -> { where.not(url_type: Platform.pluck(:name)) }
  scope :streamable, -> { where(url_type: Platform.pluck(:name)) }
  scope :info, -> { where(url_type: info_url_types) }

  with_options presence: true do
    validates :url_type
    validates :value, format: { with: URI::DEFAULT_PARSER.make_regexp }
  end

  class << self
    def popular_platforms
      platform_names = streamable.select('count(*), url_type')
        .group(:url_type)
        .having('count(*) > 0')
        .order(:count)
        .reverse_order
        .pluck(:url_type)

      platform_names.map do |platform_name|
        Platform.find_by(name: platform_name)
      end.compact
    end

    def refresh_all!
      all.each { |show_url| show_url.refresh! }
    end
  end

  def refresh!
    return if self[:url_type].to_s == 'official'

    self[:url_type] = nil
    save!
  end

  def platform
    Platform.find_by(name: url_type)
  end

  def colour
    platform&.colour
  end
  alias_method :color, :colour

  private

  def ensure_url_type
    return if url_type.present? || !value.present?

    url_to_type_regex = /(\w+\.)?(\w+)(\.\w+)/
    self[:url_type] = platform&.name || value.match(url_to_type_regex)[2]
  end
end
