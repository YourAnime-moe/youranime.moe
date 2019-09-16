# frozen_string_literal: true

class User
  class Login < ApplicationOperation
    input :username, accepts: String, type: :keyword, required: true
    input :password, accepts: String, type: :keyword, required: true
    input :maintenance, type: :keyword, required: false

    before do
      raise LoginError.new('welcome.login.errors.no-credentials') if username.blank? && password.blank?
      raise LoginError.new('welcome.login.errors.no-username') if username.blank?
      raise LoginError.new('welcome.login.errors.no-password') if password.blank?
    end

    def execute
      user = User.find_by(username: username.downcase)
      raise LoginError.new('welcome.login.errors.unknown-user', attempt: username) if user.nil?
      raise LoginError.new('welcome.login.errors.wrong-password', user: username) unless user.authenticate(password)
      raise LoginError.new('welcome.login.errors.maintenance') if maintenance && !user.admin?
      raise LoginError.new('welcome.login.errors.deactivated') unless user.active?

      user
    end

    succeeded do
      Config.slack_client&.chat_postMessage(
        channel: '#sign-ins',
        text: "[SIGN IN] User #{output.username}-#{output.id} at #{Time.zone.now}!"
      )
    end

    class LoginError < StandardError
      def initialize(i18n_key, *args, **options)
        super(I18n.t(i18n_key, *args, **options))
      end
    end
  end
end
