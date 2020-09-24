module OauthConcern
  extend ActiveSupport::Concern

  PROVIDERS_MAP = {}

  class_methods do
    def has_provider(name, klass, by)
      PROVIDERS_MAP[name.to_s] = {
        class: klass.to_s,
        identifier: by,
      }
    end

    def provider_info(provider)
      info = PROVIDERS_MAP[provider.to_s]
      oauth_class = info && info[:class]
      oauth_class = oauth_class.constantize unless oauth_class.kind_of?(Class)
      raise "Invalid OAuth provider: #{provider}" if oauth_class.nil?

      info[:class] = oauth_class
      info
    end
  end
end
