require 'discordrb'
require 'rest-client'
require 'json'

class DiscordBot
  class << self
    def run(*args)
      instance.run(*args)
    end

    def send_message(*args)
      instance.send_message(*args)
    end

    def disconnect
      instance.disconnect
    end

    private

    def instance
      return @instance if @instance
      @instance = DiscordBot.new
      @instance.setup

      @instance
    end
  end

  def setup
    @bot.command(:start) do |event, args|
      channel = event.channel.pm? ? event.channel : event.user.pm
      channel_id = channel.id

      payload = { channel_id: channel_id }

      response = RestClient.post('http://web:3000/discord/bot/register', payload)
      data = JSON.parse(response)

      messages = []

      if data['success']
        if data['persisted']
          messages << "Looks you're already good to go!"
        else
          messages << "Welcome! You'll be geting ping from me here."
        end
      else
        messages.concat([
          "Hey, oops! Looks like something went wrong when setting me up...",
          "Feel free to contact the devs with this error message: `#{data['errors'].join(' - ')}`"
        ])
      end

      event.user.pm(messages.join('\n'))
    end
  end

  def send_message(channel_id, content)
    puts(channel_id)
    puts(content)
    @bot.send_message(channel_id, nil, false, content)
  end

  def run(how = :async)
    @bot.run(how)
  end

  def disconnect
    @bot.invisible
  end

  private

  def initialize
    @bot = Discordrb::Commands::CommandBot.new(
      token: ENV.fetch("BOT_TOKEN"),
      prefix: '!',
    )
  end
end
