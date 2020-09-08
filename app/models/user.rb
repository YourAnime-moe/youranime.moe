class User < ApplicationRecord
  include TanoshimuUtils::Concerns::Identifiable
  include TanoshimuUtils::Concerns::RespondToTypes
  include TanoshimuUtils::Validators::UserLike

  REGULAR = 'regular'
  GOOGLE = 'google'
  ADMIN = 'admin'
  MISETE = 'misete'

  OAUTH_USER_TYPES = [GOOGLE, MISETE].freeze
  USER_TYPES = [REGULAR, GOOGLE, ADMIN, MISETE].freeze

  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  before_save :ensure_hex

  has_many :queues, class_name: 'Shows::Queue', inverse_of: :user
  has_many :issues, inverse_of: :user
  has_many :ratings
  has_many :shows, through: :ratings
  has_many :sessions, class_name: 'Users::Session', inverse_of: :user
  
  has_one :staff_user, class_name: 'Staff'
  has_secure_password

  respond_to_types USER_TYPES

  validate_like_user user_types: USER_TYPES
  validates :email, uniqueness: true
  validates_format_of :email, with: EMAIL_REGEX, if: :email?

  def sessions
    @sessions ||= Users::Session.where(user_id: id, user_type: user_type)
  end

  def active_sessions
    sessions.where(deleted: false).order('created_at desc')
  end

  def auth_token
    @auth_token ||= active_sessions.first&.token
  end

  def delete_auth_token!
    active_sessions.first&.delete!
  end

  def delete_all_auth_token!
    active_sessions.each { |session| session.delete! }
  end

  def can_manage?
    admin? || staff_user.present?
  end

  def progress_for(*)
    0
  end

  def rated_shows
    Show.joins(:ratings).where('user_id = ?', id)
  end

  def oauth?
    OAUTH_USER_TYPES.include?(user_type)
  end

  def self.from_google_omniauth(auth)
    where(email: auth.info.email).first_or_initialize do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.username = auth.info.email
    end
  end

  def self.from_misete_omniauth(auth)
    where(email: auth.info.email).first_or_initialize do |user|
      user.name = auth.info.first_name + " " + auth.info.last_name
      user.email = auth.info.email
      user.username = auth.info.email
      user.limited = !auth.info.active || auth.info.blocked
    end
  end

  def self.demo
    where(username: 'demo').first_or_initialize do |user|
      user.name = 'Demo User'
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
end
