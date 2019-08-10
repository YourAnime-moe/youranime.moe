class User < ApplicationRecord
  include ConnectsToShowsConcern
  include IdentifiableConcern
  include ValidateUserLikeConcern

  REGULAR = 'regular'
  GOOGLE = 'google'
  ADMIN = 'admin'

  USER_TYPES = [REGULAR, GOOGLE, ADMIN].freeze

  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  has_many :queues, class_name: 'Shows::Queue', inverse_of: :user
  has_many :sessions, class_name: 'Users::Session', inverse_of: :user
  
  has_one :staff_user, class_name: 'Staff'

  validate_like_user user_types: USER_TYPES
  validates :email, uniqueness: true
  validates_format_of :email, with: EMAIL_REGEX, if: :email?

  def sessions
    Users::Session.where(user_id: id, user_type: user_type)
  end

  def active_sessions
    sessions.where(deleted: false)
  end
end
