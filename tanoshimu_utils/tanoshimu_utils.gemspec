
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tanoshimu_utils/version"

Gem::Specification.new do |spec|
  spec.name          = 'tanoshimu_utils'
  spec.version       = TanoshimuUtils::VERSION
  spec.authors       = ['Akinyele Cafe-Febrissy']
  spec.email         = ['me@akinyele.ca']
  spec.date          = '2020-01-01'

  spec.summary       = 'YourAnime.moe utilities'
  spec.description   = 'Just a couple of utilities shared accross the apps to make development much easier.'
  spec.homepage      = 'https://github.com/thedrummeraki/tanoshimu/tree/heroku/tanoshimu_utils'

=begin
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end
=end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.

  spec.files         = Dir['lib/**/*']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency 'activesupport'
end
