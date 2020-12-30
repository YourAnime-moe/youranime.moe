# frozen_string_literal: true
class ShowUrl < ApplicationRecord
  WATCHABLE_URL_TYPES = %w[youtube youtu].freeze
  STREAMABLE_URL_TYPES = %i(funimation crunchyroll netflix vrv hulu hidive animelab prime vimeo tubi adultswim)
  INFO_URL_TYPES = %i(twitter official)

  COLOUR_MAP = {
    funimation: '#410099',
    crunchyroll: '#f78c25',
    netflix: '#e50914',
    vrv: '#ffea62',
    hulu: '#1ce783',
    hidive: '#00aeef',
    animelab: '#350079',
    prime: '#266f92',
    vimeo: '#eef1f2',
    tubi: '#26262d',
    adultswim: '#000000',

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

  class << self
    def popular_platforms
      streamable.select('count(*), url_type')
        .group(:url_type)
        .having('count(*) > 0')
        .order(:count)
        .reverse_order
        .pluck(:url_type)
    end

    def colour_for(platform)
      COLOUR_MAP[platform.to_sym]
    end

    def refresh_all!
      all.each { |show_url| show_url.refresh! }
    end
  end

  def platform
    return :youtube if has_domain?('youtube.com', 'youtu.be')
    return :netflix if has_domain?('netflix.com')
    return :funimation if has_domain?('funimation.com')
    return :crunchyroll if has_domain?('crunchyroll.com')
    return :vrv if has_domain?('vrv.co')
    return :hulu if has_domain?(/hulu./)
    return :hidive if has_domain?('hidive.com')
    return :animelab if has_domain?('animelab.com')
    return :twitter if has_domain?('twitter.com')
    return :prime if has_domain?(/amazon/, 'primevideo.com')
    return :vimeo if has_domain?(/vimeo/)
    return :tubi if has_domain?('tubitv.com')
    return :adultswim if has_domain?('adultswim.com')

    return :official if url_type == 'official'

    :unknown
  end

  def colour
    COLOUR_MAP[platform]
  end

  def refresh!
    return if self[:url_type].to_s == 'official' 

    self[:url_type] = nil
    save!
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

    # url_to_type_regex = /(\w+\.)?(\w+)(\.\w+)/
    self[:url_type] = platform # value.match(url_to_type_regex)[2]
  end
end
