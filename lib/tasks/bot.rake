namespace :discord do
  namespace :bot do
    task(run: :environment) do
      puts("Running discord bot...")
      bot_instance = Subscriptions::Discord::Bot.instance
      at_exit { Subscriptions::Discord::Bot.mark_invisible! }

      bot_instance.run
    end
  end
end
