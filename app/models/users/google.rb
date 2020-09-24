module Users
  class Google < Oauth
    def user_type
      Oauth::GOOGLE
    end
  end
end
