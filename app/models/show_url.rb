class ShowUrl < ApplicationRecord
  WATCHABLE_URL_TYPES = ['youtube', 'youtu'].freeze

  belongs_to :show, inverse_of: :urls
  before_validation :ensure_url_type, unless: :url_type

  scope :watchable, -> { where(url_type: WATCHABLE_URL_TYPES) }
  scope :non_watchable, -> { where.not(url_type: WATCHABLE_URL_TYPES) }

  with_options presence: true do
    validates :url_type
    validates :value, format: { with: URI.regexp }
  end

  def youtube?
    has_domain? 'youtube.com', 'youtu.be'
  end

  def netflix?
    has_domain? 'netflix.com'
  end

  def funimation?
    has_domain? 'funimation.com'
  end

  def crunchyroll?
    has_domain? 'crunchyroll.com'
  end

  def vrv?
    has_domain? 'vrv.co'
  end

  def hulu?
    has_domain? 'hulu.com'
  end

  def hidive?
    has_domain? 'hidive.com'
  end

  private

  def has_domain?(*domains)
    domains.select do |domain|
      value.include?(domain)
    end.any?
  end

  def ensure_url_type
    return unless value.present?

    url_to_type_regex = %r{(\w+\.)?(\w+)(\.\w+)}
    self[:url_type] = value.match(url_to_type_regex)[2]
  end
end
