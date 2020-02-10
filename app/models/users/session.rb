module Users
  class Session < ApplicationRecord
    before_destroy :prevent_destroy!
    before_validation :ensure_token

    validate :user_present
    validates :token, presence: true, uniqueness: true
    validates :deleted, inclusion: { in: [true, false] }
    validates :active_until, presence: true

    alias_attribute :active_since, :created_at

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

    def self.authenticated_with(token)
      where(deleted: false).find_by(token: token)
    end

    private

    def prevent_destroy!
      throw :abort
    end

    def ensure_token
      return if token.present?

      loop do
        self.token = SecureRandom.hex
        break if self.class.where(token: token).empty?
      end
    end

    def user_present
      unless user.present?
        errors.add(:user, 'is missing')
      end
    end
  end
end
