module Discord
  class OauthController < ApplicationController
    def new
      credentials = Rails.application.credentials.discord[Rails.env]
      query = {
        client_id: credentials.client_id,
        redirect_uri: credentials.redirect_uri,
        scope: ['identify'].join(' '),
        response_type: "code",
      }

      uri = URI::HTTPS.build(
        host: 'discord.com',
        path: '/api/oauth2/authorize',
        query: query.to_query,
      )

      redirect_to(uri.to_s)
    end

    def create
      credentials = Rails.application.credentials.discord[Rails.env]
      payload = {
        code: params[:code],
        client_id: credentials.client_id,
        client_secret: credentials.client_secret,
        grant_type: "authorization_code",
        redirect_uri: credentials.redirect_uri,
      }

      uri = URI::HTTPS.build(
        host: 'discord.com',
        path: '/api/v10/oauth2/token'
      )

      response = RestClient.post(uri.to_s, payload, {"Content-Type": "application/x-www-form-urlencoded"})


      render(json: JSON.parse(response))
    end

    private

    def current_user
      return @current_user if @current_user.present?

      proxied_auth_uuid = request.headers['X-Proxied-Auth-ID']
      return unless proxied_auth_uuid.present?

      @current_user ||= GraphqlUser.find_or_create_by(uuid: proxied_auth_uuid)
    end
  end
end
