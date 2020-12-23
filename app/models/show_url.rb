# frozen_string_literal: true
class ShowUrl < ApplicationRecord
  WATCHABLE_URL_TYPES = %w[youtube youtu].freeze
  STREAMABLE_URL_TYPES = %i(funimation crunchyroll netflix vrv hulu hidive animelab)
  INFO_URL_TYPES = %i(twitter official)

  COLOUR_MAP = {
    funimation: '#410099',
    crunchyroll: '#f78c25',
    netflix: '#e50914',
    vrv: '#ffea62',
    hulu: '#1ce783',
    hidive: '#00aeef',
    animelab: '#350079',

    twitter: '#1DA1F2',
    official: '#bbbbbb',

    unknown: '#aaaaaa',
  }.freeze

  belongs_to :show, inverse_of: :urls
  before_validation :ensure_url_type, unless: :url_type

  scope :watchable, -> { where(url_type: WATCHABLE_URL_TYPES) }
  scope :non_watchable, -> { where.not(url_type: WATCHABLE_URL_TYPES) }
  scope :streamable, -> { where(url_type: STREAMABLE_URL_TYPES) }
  scope :info, -> { where(url_type: INFO_URL_TYPES) }

  with_options presence: true do
    validates :url_type
    validates :value, format: { with: URI::DEFAULT_PARSER.make_regexp }
  end

  def youtube?
    has_domain?('youtube.com', 'youtu.be')
  end

  def netflix?
    has_domain?('netflix.com')
  end

  def funimation?
    has_domain?('funimation.com')
  end

  def crunchyroll?
    has_domain?('crunchyroll.com')
  end

  def vrv?
    has_domain?('vrv.co')
  end

  def hulu?
    has_domain?(/hulu./)
  end

  def hidive?
    has_domain?('hidive.com')
  end

  def animelab?
    has_domain?('animelab.com')
  end

  def platform
    return :youtube if youtube?
    return :netflix if netflix?
    return :funimation if funimation?
    return :crunchyroll if crunchyroll?
    return :vrv if vrv?
    return :hulu if hulu?
    return :hidive if hidive?
    return :animelab if animelab?
    return :twitter if has_domain?('twitter.com')
    return :official if url_type == 'official'

    :unknown
  end

  def colour
    COLOUR_MAP[platform]
  end

  private

  def has_domain?(*domains)
    domains.select do |domain|
      if domain.is_a?(Regexp)
        value =~ domain
      else
        value.include?(domain)
      end
    end.any?
  end

  def ensure_url_type
    return if url_type.present? || !value.present?

    url_to_type_regex = /(\w+\.)?(\w+)(\.\w+)/
    self[:url_type] = value.match(url_to_type_regex)[2]
  end
end
