# frozen_string_literal: true

require_relative 'lib/riteway/version'

Gem::Specification.new do |spec|
  spec.name          = 'riteway'
  spec.version       = Riteway::VERSION
  spec.authors       = ['Mikey Hargiss']

  spec.summary       = 'Simple, readable, helpful unit tests in Ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'source_code_uri' => 'https://github.com/mycargus/riteway-ruby',
    'changelog_uri' => 'https://github.com/mycargus/riteway-ruby/blob/master/CHANGELOG.md'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.13'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '~> 0.89.1'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.10'
end
