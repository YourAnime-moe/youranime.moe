Config.setup do |config|
  config.domain = ENV['MAIN_HOST'] || ''
  config.videojs = '5.16.0'
  config.bulma_version = '0.7.4'
  config.api_version = 1
end

p "setup!"
