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
  end
end
