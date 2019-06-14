# frozen_string_literal: true

class User
  class Login < ApplicationOperation
    input :username, accepts: String, type: :keyword, required: true
    input :password, accepts: String, type: :keyword, required: true
    input :maintenance, type: :keyword, required: false

    before do
      raise LoginError, 'welcome.login.errors.no-credentials' if username.blank? && password.blank?
      raise LoginError, 'welcome.login.errors.no-username' if username.blank?
      raise LoginError, 'welcome.login.errors.no-password' if password.blank?
    end

    def execute
      user = User.find_by(username: username.downcase)
      raise LoginError, 'welcome.login.errors.unknown-user' if user.nil?
      raise LoginError, 'welcome.login.errors.wrong-password' unless user.authenticate(password)
      raise LoginError, 'welcome.login.errors.maintenance' if maintenance && !user.admin?
      raise LoginError, 'welcome.login.errors.deactivated' unless user.is_activated?

      user
    end

    succeeded do
      Config.slack_client&.chat_postMessage(
        channel: '#sign-ins',
        text: "[SIGN IN] User #{output.username}-#{output.id} at #{Time.zone.now}!"
      )
    end

    class LoginError < StandardError
      def initialize(i18n_key)
        super(i18n_key)
      end
    end
  end
end
