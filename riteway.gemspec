Gem::Specification.new do |spec|
  spec.name        = "riteway"
  spec.version     = "0.1.0"
  spec.summary     = "Unit tests that always supply a good bug report when they fail."
  spec.description = "Ruby port of the riteway JavaScript testing library."
  spec.authors     = ["Michael Hargiss"]
  spec.license     = "MIT"
  spec.homepage    = "https://github.com/mycargus/riteway-ruby"

  # Publishing must be done manually by a human. No automated publishing.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files       = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "rspec-expectations", ">= 3.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "minitest", ">= 5.0"
end
