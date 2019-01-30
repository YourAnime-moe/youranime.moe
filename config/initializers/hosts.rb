Config.setup do |config|
  config.domain = ENV['MAIN_HOST'] || ''
  config.videojs = '5.16.0'
end
