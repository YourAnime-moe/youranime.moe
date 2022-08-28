# frozen_string_literal: true
class Admin::GraphqlController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  class UnauthorizedUserError < StandardError; end
  
  before_action :ensure_admin_bearer_token!

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    country = request.headers['X-Country']
    timezone = request.headers['X-Timezone']

    context = {
      hostname: hostname,
      country: country || 'CA',
      timezone: timezone || 'America/Toronto',
      is_default: country.blank? || timezone.blank?,
      current_user: current_user,
    }
    result = AdminSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render(json: result)
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def hostname
    Rails.application.config.x.graphql_host || request.protocol + request.host_with_port
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error(e.message)
    logger.error(e.backtrace.join("\n"))

    render(json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500)
  end

  def current_user
    @current_user
  end

  def ensure_admin_bearer_token!
    valid_token = authenticate_with_http_token do |token|
      @current_user = find_user_from_token(token)
    end

    return if @current_user.present?

    render(json: { error: true, message: "Bearer token invalid/missing or authorized user" }, status: 401)
  end

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

