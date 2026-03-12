require_relative "lib/riteway/version"

Gem::Specification.new do |spec|
  spec.name        = "riteway"
  spec.version     = Riteway::VERSION
  spec.summary     = "Unit tests that always supply a good bug report when they fail."
  spec.description = "Ruby port of the riteway JavaScript testing library."
  spec.authors     = ["Michael Hargiss"]
  spec.license     = "MIT"
  spec.homepage    = "https://github.com/mycargus/riteway-ruby"

  # Publishing must be done manually by a human. No automated publishing.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["changelog_uri"]     = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"]   = "#{spec.homepage}/issues"

  spec.files       = Dir["lib/**/*.rb"] + ["LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "rspec-expectations", ">= 3.0"
  spec.add_development_dependency "minitest", ">= 5.0"
end
