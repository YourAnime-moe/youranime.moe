module Users
  class Oauth < User
    include TanoshimuUtils::Concerns::RespondToTypes

    GOOGLE = 'google'
    MISETE = 'misete'
    OAUTH_USER_TYPES = [GOOGLE, MISETE].freeze

    respond_to_types OAUTH_USER_TYPES

    def oauth?
      true
    end

    def can_comment?
      true
    end

    def can_like?
      valid?
    end

    def can_login?
      valid?
    end
  end
end
