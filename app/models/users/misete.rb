module Users
  class Misete < Oauth
    def user_type
      Oauth::MISETE
    end
  end
end
