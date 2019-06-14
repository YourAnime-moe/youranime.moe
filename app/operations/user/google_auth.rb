# frozen_string_literal: true

class User
  class GoogleAuth < ApplicationOperation
    input :access_token, accepts: OmniAuth::AuthHash, type: :keyword, required: true

    def execute
      user = User.from_omniauth(access_token)
      return nil if user.persisted? && user.google_user
      raise NotGoogleUser, 'welcome.google.not-google' if user.persisted?

      refresh_token = access_token.credentials.refresh_token
      user.google_token = access_token.credentials.token
      user.google_refresh_token = refresh_token if refresh_token.present?
      user
    end

    succeeded do
      I18n.locale = access_token.locale
    rescue StandardError
      Rails.logger.error "Unsupported locale provided by Google: #{access_token.info.locale}"
    end

    class NotGoogleUser < StandardError; end
  end
end
