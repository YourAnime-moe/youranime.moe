require 'sinatra'
require 'jwt'
require_relative 'bot'

DiscordBot.run(:async)

get '/' do
  'bot is running'
end

get '/ping' do
  'Pong. Bot is running.'
end

post '/webhook/message' do
  request.body.rewind
  data = JSON.parse(request.body.read)

  jwt_token = data['jwt_token']

  if jwt_token
    payload = JWT.decode(jwt_token, ENV.fetch("BOT_TOKEN"), true, { algorithm: 'HS512' })[0]
    channel_id = payload['channel_id']
    embed_data = payload['embed']
    if channel_id && embed_data
      embed_options = embed_data.transform_keys(&:to_sym)
      embed = Discordrb::Webhooks::Embed.new(**embed_options)

      DiscordBot.send_message(channel_id, embed)
    end
    
    JSON.generate({success: true})
  else  
    status(400)
    JSON.generate({success: false, error: "Missing JWT token"})
  end
rescue JWT::DecodeError
  status(400)
  JSON.generate({success: false, error: "Invalid JWT token"})
rescue JSON::ParserError
  status(400)
  JSON.generate({success: false, error: "Expected JSON body"})
end

at_exit { DiscordBot.disconnect }
