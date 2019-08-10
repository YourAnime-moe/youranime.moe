class Staff < ApplicationRecord
  include ConnectsToShowsConcern
  include IdentifiableConcern
  include ValidateUserLikeConcern

  ADMIN = 'staff-admin'
  REGULAR = 'staff'
  GUEST = 'staff-guest'
  DEMO = 'staff-demo'

  USER_TYPES = [ADMIN, REGULAR, GUEST, DEMO].freeze

  validate_like_user user_types: USER_TYPES

  def user
    @user ||= User.where(id: user_id).first
  end

  def to_user!
    return user if user.present?

    new_user = User.create!(
      user_type: User::REGULAR,
      username: username,
      name: name,
      active: true,
      limited: false,
    )

    update!(user_id: new_user.id)
    new_user
  end
end
