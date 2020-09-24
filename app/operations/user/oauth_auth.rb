module Users
  class OauthAuth < ApplicationOperation
    property! :access_token, accepts: OmniAuth::AuthHash

    def execute
      authenticate!
    end

    private

    def authenticate!
      oauth_user = OauthUser.from_omniauth(access_token)
      update_user(oauth_user)

      return oauth_user if oauth_user.valid_oauth_user?
      raise OauthUser::InvalidOauthUser unless oauth_user.oauth?
      raise Users::Session::InactiveError if oauth_user.persisted? && !oauth_user.active?

      prepare_oauth_user(oauth_user)
    end

    def update_user(oauth_user)
      oauth_user.class.update_user_info(oauth_user, access_token)
    end

    def prepare_oauth_user(oauth_user)
      oauth_user.active = true
      oauth_user.save
      return oauth_user if oauth_user.valid?

      Rails.logger.error(
        "[Users::Oauth::Authenticate] Invalid #{oauth_user.class}: #{oauth_user.errors.to_a}",
      )
      nil
    end
  end
end
