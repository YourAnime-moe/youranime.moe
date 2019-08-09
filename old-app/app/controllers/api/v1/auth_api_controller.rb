module Api
  module V1
    class AuthApiController < Api::ApplicationController
      before_action :ensure_token
    end
  end
end
