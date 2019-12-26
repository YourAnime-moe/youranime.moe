$:.push File.expand_path("lib", __dir__)

require 'tanoshimu_utils/version'

Gem::Specification.new do |s|
  s.name        = 'tanoshimu-utils'
  s.version     = TanoshimuUtils::VERSION
  s.date        = '2020-01-01'
  s.summary     = "YourAnime.moe utilities"
  s.description = "Just a couple of utilities shared accross the apps to make development much easier."
  s.authors     = ["Akinyele Cafe-Febrissy"]
  s.email       = 'me@akinyele.ca'
  s.files       = Dir["{lib}/**/*"]
  s.homepage    =
    'https://github.com/thedrummeraki'
  s.license       = 'MIT'

  s.add_dependency 'activesupport'
end
