module Users
  class ThatCanLogin < User
    self.abstract_class = true

    has_secure_password

    def can_comment?
      true
    end

    def can_login?
      valid?
    end
  end
end
