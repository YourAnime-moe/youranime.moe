# frozen_string_literal: true

class User
  class Login < ApplicationOperation
    input :username, accepts: String, type: :keyword, required: true
    input :password, accepts: String, type: :keyword, required: true
    input :fingerprint, type: :keyword, required: true
    input :maintenance, type: :keyword, required: false

    before do
      raise LoginError.new('welcome.login.errors.no-credentials') if username.blank? && password.blank?
      raise LoginError.new('welcome.login.errors.no-username') if username.blank?
      raise LoginError.new('welcome.login.errors.no-password') if password.blank?
      raise LoginError.new('fingerprint.missing') if fingerprint.blank?
    end

    def execute
      user = User.find_by(username: username.downcase)
      raise LoginError.new('welcome.login.errors.unknown-user', attempt: username) if user.nil?
      raise LoginError.new('welcome.login.errors.wrong-password', user: username) unless user.authenticate(password)
      raise LoginError.new('welcome.login.errors.maintenance') if maintenance && !user.admin?
      raise LoginError.new('welcome.login.errors.deactivated') unless user.active?

      activate_session!(user)
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

    private

    def activate_session!(user)
      items = fingerprint[:items]
      fprint = fingerprint[:print]

      device_id = fprint
      device_name = items["0"]["value"]
      device_location = items["9"]["value"]
      device_os = items["16"]["value"]

      device_unknown = [device_id, device_name, device_location, device_os].compact.empty?

      user.sessions.create!(
        active_until: 1.week.from_now,
        device_id: device_id,
        device_name: device_name,
        device_location: device_location,
        device_os: device_os,
        device_unknown: device_unknown
      )
      user
    end
  end
end
