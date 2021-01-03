# frozen_string_literal: true
module Users
  class Misete < Oauth
    class << self
      def fillup_user_info(user, oauth)
        user.username = oauth.info.username
        user.email = user.persisted? ? user.email : oauth.info.email || "#{oauth.uid}@dummy-misete.io"
      end

      def update_user_info(user, oauth)
        user.first_name = oauth.info.first_name
        user.last_name = oauth.info.last_name
        user.active = oauth.info.active
        user.hex = oauth.info.color_hex

        avatar_file = try_download_avatar(oauth.info.image)
        user.avatar.attach(io: avatar_file, filename: "#{user.username}-avatar") if avatar_file
      end

      private

      def try_download_avatar(uri)
        Down.download(uri)
      rescue => e
        Rails.logger.error(e)
        nil
      end
    end

    def provider
      Oauth::MISETE
    end
  end
end
