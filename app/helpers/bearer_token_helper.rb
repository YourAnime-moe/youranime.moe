module BearerTokenHelper
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def find_user_from_token(token)
    Rails.logger.info("Fetching token info...")
    response = RestClient.get(
      "https://id.youranime.moe/me.json",
      { 'Authorization' => "Bearer #{token}" }
    )

    body = JSON.parse(response.body)
    if body['blocked'] || !body['active']
      Rails.logger.error("User is blocked or not active")
      return
    end

    user = Users::Admin.find_or_initialize_by(username: body['username'])

    user.identification = body['uuid']
    user.first_name = body['first_name']
    user.last_name = body['last_name']
    unless user.persisted?
      user.password = SecureRandom.hex
    end

    user.save!
  rescue RestClient::Unauthorized => error
    Rails.logger.error(error)
    nil
  end
end
