# frozen_string_literal: true
module Users
  class Google < Oauth
    def provider
      Oauth::GOOGLE
    end
  end
end
