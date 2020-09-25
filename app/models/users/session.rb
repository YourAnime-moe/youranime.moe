module Users
  class Session < ApplicationRecord
    before_destroy :prevent_destroy!
    before_validation :ensure_token

    validate :user_present
    validates :token, presence: true, uniqueness: true
    validates :deleted, inclusion: { in: [true, false] }
    validates :active_until, presence: true

    class InactiveError < StandardError; end

    def user
      User.where(user_type: user_type, id: user_id).first
    end

    def user=(user)
      return unless user.respond_to?(:user_type)

      self.user_type = user.user_type
      self.user_id = user.id
      user
    end

    def expired?
      active_until < Time.now.utc
    end

    def active?
      !expired?
    end

    def deleted?
      self[:deleted] && deleted_on?
    end

    def delete!
      return if deleted?

      User.transaction do
        update!(
          deleted: true,
          deleted_on: Time.now.utc,
          active_until: Time.now.utc
        )
      end
    end

    private

    def prevent_destroy!
      throw :abort
    end

    def ensure_token
      return if self.token.present?

      self.token = SecureRandom.hex
      until self.class.where(token: self.token)
        self.token = SecureRandom.hex
      end
    end

    def user_present
      unless user.present?
        errors.add(:user, 'is missing')
      end
    end
  end
end
