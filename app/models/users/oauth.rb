# frozen_string_literal: true
module Users
  class Oauth < User
    include OauthConcern
    include TanoshimuUtils::Concerns::RespondToTypes

    has_provider :misete, 'Users::Misete', by: :username, show_name: 'Misete Accounts'
    has_provider :google, 'Users::Google', by: :email, show_name: 'Google'

    GOOGLE = 'google'
    MISETE = 'misete'
    OAUTH_USER_TYPES = [GOOGLE, MISETE].freeze

    respond_to_types OAUTH_USER_TYPES

    class InvalidOauthUser < StandardError; end

    class << self
      def from_omniauth(auth)
        info = provider_info(auth.provider)
        oauth_class = info[:class]
        oauth_identifier = info[:identifier]

        oauth_class.where(
          username: auth.info.send(oauth_identifier),
        ).first_or_initialize do |user|
          oauth_class.fillup_user_info(user, auth)
        end
      end

      def fillup_user_info(*)
        raise 'Invalid Oauth user class.'
      end

      def update_user_info(*)
        raise 'Invalid Oauth user class.'
      end
    end

    def initialize(*args)
      super
      self.user_type = provider
      self
    end

    def provider
      raise 'Invalid Oauth user. Use a subclass of this class.'
    end

    def oauth?
      true
    end

    def valid_oauth_user?
      provider && persisted? && user_type?
    rescue => e
      Rails.logger.error(e)
      false
    end

    def can_comment?
      true
    end

    def can_like?
      valid?
    end
  end
end
