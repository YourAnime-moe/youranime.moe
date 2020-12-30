# frozen_string_literal: true
module Users
  class Admin < ThatCanLogin
    def can_like?
      false
    end

    def can_comment?
      false
    end

    def can_manage?
      true
    end

    def self.system
      user = find_or_initialize_by(username: 'system') do |new_user|
        new_user.first_name = '*System'
        new_user.last_name = 'User'
        new_user.password = SecureRandom.hex
      end

      user.save!
      user
    end
  end
end
