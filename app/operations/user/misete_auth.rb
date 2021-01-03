# frozen_string_literal: true

class User
  class MiseteAuth < ApplicationOperation
    input :access_token, accepts: OmniAuth::AuthHash, type: :keyword, required: true

    def execute
      user = User.from_misete_omniauth(access_token)
      return user if user.persisted? && user.misete?
      raise NotMiseteUser, 'welcome.google.not-google' if user.persisted?

      user
    end

    succeeded do
      I18n.locale = access_token.locale
    rescue StandardError
      Rails.logger.error("Unsupported locale provided by Google: #{access_token.info.locale}")
    end

    class NotMiseteUser < StandardError; end
  end
end
