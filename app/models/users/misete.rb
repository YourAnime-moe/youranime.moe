module Users
  class Misete < Oauth
    def provider
      Oauth::MISETE
    end

    def self.fillup_user_info(user, oauth)
      user.username = oauth.info.username
      user.email = user.persisted? ? user.email : oauth.info.email || "#{oauth.uid}@dummy-misete.io"
    end

    def self.update_user_info(user, oauth)
      user.first_name = oauth.info.first_name
      user.last_name = oauth.info.last_name
      user.active = oauth.info.active
      user.hex = oauth.info.color_hex

      avatar_file = Down.download(oauth.info.image)
      user.avatar.attach(io: avatar_file, filename: "#{user.username}-avatar")
    end
  end
end
