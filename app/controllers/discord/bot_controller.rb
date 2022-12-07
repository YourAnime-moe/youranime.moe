module Discord
  class BotController < ActionController::API
    before_action :ensure_valid_bot_request!
  
    def register
      channel_id = params[:channel_id]
      account_uuid = params[:account_uuid]
      user_id = params[:user_id]

      user_subscription = UserSubscription.find_or_initialize_by(
        platform: "discord",
        platform_user_id: channel_id.to_s,
      )

      if user_subscription.persisted?
        render(json: { success: true, persisted: true })
      else
        graphql_user = GraphqlUser.find_or_create_by(uuid: account_uuid)
        user_subscription.user = graphql_user

        user_subscription.assign_attributes(subscription_type: "airing-info")
        if user_subscription.save
          render(json: {
            success: true,
          })
        else
          render(json: { success: false, errors: user_subscription.errors.to_a })
        end
      end
    end
  
    private
  
    def ensure_valid_bot_request!
    end

    def find_user_by_discord_user_id(discord_user_id)
      puts("DISOCRD ID #{discord_user_id}")
    end
  end
end
