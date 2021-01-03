# frozen_string_literal: true
module Users
  class Regular < ThatCanLogin
    def can_like?
      valid?
    end

    def can_login?
      valid?
    end
  end
end
