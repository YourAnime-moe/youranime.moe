Config.setup do |config|
  config.domain = ENV['MAIN_HOST'] || ''
  config.videojs = '5.16.0'
  config.api_version = 1
end
