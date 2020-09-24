class User < ApplicationRecord
  include LikeableConcern
  include HasSessionsConcern
  include TanoshimuUtils::Concerns::Identifiable

  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  before_save :ensure_hex
  can_like_as :user

  has_many :queues, -> {
    includes(shows_queue_relations: {
      show: [:description_record, :title_record, :ratings],
    })
  }, class_name: 'Shows::Queue', inverse_of: :user
  has_many :issues, inverse_of: :user
  has_many :ratings
  has_many :shows, through: :ratings
  has_many :sessions, class_name: 'Users::Session', inverse_of: :user
  has_many :uploads, inverse_of: :user
  has_one :staff_user, class_name: 'Staff'

  validate :valid_user_type
  validates :email, uniqueness: true
  validates :first_name, presence: true
  validates_format_of :email, with: EMAIL_REGEX, if: :email?

  def name
    I18n.t('user.format.name', first: first_name, last: last_name).strip
  end

  def rated_shows
    Show.joins(:ratings).where('user_id = ?', id)
  end

  def add_show_to_main_queue(show)
    return if main_queue.include?(show)

    main_queue << show
  end

  def remove_show_from_main_queue(show)
    main_queue - show
  end

  def has_show_in_main_queue?(show)
    main_queue.include?(show)
  end

  def main_queue
    @main_queue ||= queues.empty? ? queues.create! : queues.first
  end

  def can_login?
    false
  end

  def can_like?
    false
  end

  def oauth?
    false
  end

  def can_comment?
    false
  end

  def can_manage?
    false
  end

  def self.from_google_omniauth(auth)
    where(email: auth.info.email).first_or_initialize do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.username = auth.info.email
    end
  end

  def self.demo
    where(username: 'demo').first_or_initialize do |user|
      user.name = 'Demo User'
      user.password = SecureRandom.hex
      user.email = 'demo@youranime.moe'
    end
  end

  private

  def ensure_hex
    return if hex && hex != self.class.new.hex

    hash_code = 0
    username.each_char do |char|
      hash_code = char.ord + ((hash_code << 5) - hash_code)
    end

    code = hash_code & 0x00FFFFFF
    code = code.to_s(16).upcase

    self[:hex] = '#' << '00000'[0, 6 - code.size] + code
  end

  def valid_user_type
    unless type != User.name
      errors.add(:type, "must not be of type #{User.name}")
    end
  end
end
