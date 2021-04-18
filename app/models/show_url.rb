# frozen_string_literal: true
class ShowUrl < ApplicationRecord
  COLOURS = {
    twitter: '#00ACEE',
  }.with_indifferent_access.freeze

  belongs_to :show, inverse_of: :urls
  before_validation :ensure_url_type, unless: :url_type

  scope :ordered, -> { order(:url_type) }
  scope :watchable, -> { where(url_type: []) }
  scope :non_watchable, -> { where.not(url_type: Platform.pluck(:name)) }
  scope :streamable, -> (for_country: nil) { where(url_type: Platform.for_country(for_country).pluck(:name)) }
  scope :info, -> { where(url_type: info_url_types) }

  with_options presence: true do
    validates :url_type
    validates :value, format: { with: URI::DEFAULT_PARSER.make_regexp }
  end

  class << self
    def popular_platforms(for_country: nil)
      platform_names = streamable.select('count(*), url_type')
        .group(:url_type)
        .having('count(*) > 0')
        .order(:count)
        .reverse_order
        .pluck(:url_type)

      scope = for_country ? :for_country : :all
      scope_options = for_country ? [for_country] : []

      platform_names.map do |platform_name|
        Platform.send(scope, *scope_options).find_by(name: platform_name)
      end.compact
    end

    def refresh_all!
      all.each(&:refresh!)
    end
  end

  def refresh!
    return if self[:url_type].to_s == 'official'

    self[:url_type] = nil
    save!
  end

  def platform
    result = Platform.find_by(name: url_type)
    return result if result.present?

    Platform.from(value)
  end

  def colour
    platform&.colour || COLOURS[url_type]
  end
  alias_method :color, :colour

  private

  def ensure_url_type
    return if url_type.present? || !value.present?

    url_to_type_regex = /(\w+\.)?(\w+)(\.\w+)/
    self[:url_type] = platform&.name || value.match(url_to_type_regex)[2]
  end
end
