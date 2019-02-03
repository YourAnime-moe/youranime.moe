module Api
  class ApiError < StandardError
    def as_json(options={})
      {success: false, status: http_status, type: self.class}.merge(additional_parameters)
    end

    def additional_parameters
      {}
    end

    def http_status
      500
    end
  end

  class BaseApiError < ApiError
    def initialize(message)
      @message = message
    end

    def additional_parameters
      {message: @message}
    end
  end

  class LoginApiError < BaseApiError
    def additional_parameters
      super.merge({token: nil})
    end

    def http_status
      403
    end
  end

  class InvalidIDError < ApiError
    def initialize(error, valid, message=nil, value=nil)
      @error = error
      @valid = valid
      @message = message || "Invalid id."
      @value = value
    end

    def additional_parameters
      params = {error: @error, valid: @valid, message: @message, value: @value}
      params.delete :error unless @error
      params.delete :value unless @value
      params
    end
  end

  class MissingTokenError < LoginApiError
    def initialize
      super("Access denied. No token was specified.")
    end
  end

  class InvalidTokenError < LoginApiError
    def initialize
      super("Your session has been terminated... Did you login on another device?")
    end
  end

  class MissingCredentialsError < LoginApiError
    def initialize
      super("You forgot to enter your username and password!")
    end
  end

  class InvalidCredentialsError < LoginApiError
    def initialize
      super("Please send your username and password encoded in Base64 format.")
    end
  end

  class UserNotFoundError < LoginApiError
    def initialize
      super("Invalid username or password.")
    end
  end

  class UndergoingMaintenanceError < LoginApiError
    def initialize
      super("Sorry, this site is undergoing maintenance as we speak! Please check back later.")
    end
  end

  class NotAdminError < LoginApiError
    def initialize
      super("Access denied. This action requires to be an admin.")
    end

    def additional_parameters
      super.merge({
        rails_message: "Access denied. This action requires to be an admin.",
        show_login: true,
        show_login_message: "Re-login"
      })
    end
  end

  class UserNotActivatedError < LoginApiError
    def initialize
      super("Sorry, you do not have access to Tanoshimu at the moment. Your account is currenlty deactivated.")
    end
  end
end
