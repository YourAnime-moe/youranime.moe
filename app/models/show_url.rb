# frozen_string_literal: true
class ShowUrl < ApplicationRecord
  include HasPlatformConcern

  belongs_to :show, inverse_of: :urls
  before_validation :ensure_url_type, unless: :url_type

  has_platform :adultswim, colour: '#000000', detect_from: /adultswim.com/, img: 'adultswim.png',
info_url: 'funimation.com'
  has_platform :animelab, colour: '#350079', detect_from: /animelab.com/, img: 'animelab.png',
info_url: 'funimation.com'
  has_platform :crunchyroll, colour: '#f78c25', detect_from: /crunchyroll.com/, img: 'crunchyroll.svg',
info_url: 'funimation.com'
  has_platform :funimation, colour: '#410099', detect_from: /funimation.com/, img: 'funimation.svg',
info_url: 'funimation.com'
  has_platform :hidive, colour: '#00aeef', detect_from: /hidive.com/, img: 'hidive.svg', info_url: 'funimation.com'
  has_platform :hulu, colour: '#1ce783', detect_from: /hulu./, img: 'hulu.png', info_url: 'funimation.com'
  has_platform :netflix, colour: '#e50914', detect_from: /netflix.com/, img: 'netflix.svg', info_url: 'funimation.com'
  has_platform :prime, colour: '#266f92', detect_from: [/amazon/, /primevideo.com/], img: 'primevideo.png',
info_url: 'funimation.com'
  has_platform :tubi, colour: '#26262d', detect_from: /tubitv.com/, img: 'tubi.png', info_url: 'funimation.com'
  has_platform :vimeo, colour: '#eef1f2', detect_from: /vimeo/, img: 'vimeo.svg', info_url: 'funimation.com',
streamable: false, watchable: true
  has_platform :vrv, colour: '#ffea62', detect_from: /vrv.co/, img: 'vrv.svg', info_url: 'funimation.com'
  has_platform :youtube, colour: '#ff0000', detect_from: [/youtube.com/, /youtu.be/], img: 'youtube.png',
info_url: 'youtube.com', streamable: false, watchable: true

  has_info_link :official, colour: '#bbbbbb'
  has_info_link :twitter, colour: '#1DA1F2'

  scope :watchable, -> { where(url_type: watchable_url_types) }
  scope :non_watchable, -> { where.not(url_type: watchable_url_types) }
  scope :streamable, -> { where(url_type: streamable_url_types) }
  scope :info, -> { where(url_type: info_url_types) }

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

    def refresh_all!
      all.each { |show_url| show_url.refresh! }
    end
  end

  def refresh!
    return if self[:url_type].to_s == 'official'

    self[:url_type] = nil
    save!
  end

  private

  def ensure_url_type
    return if url_type.present? || !value.present?

    # url_to_type_regex = /(\w+\.)?(\w+)(\.\w+)/
    self[:url_type] = platform # value.match(url_to_type_regex)[2]
  end
end
