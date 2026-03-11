begin
  require "rspec/expectations"
  require "rspec/matchers"
rescue LoadError
  raise LoadError,
    "riteway/rspec requires the 'rspec' gem. Add `gem \"rspec\"` to your Gemfile, " \
    "or use `require \"riteway/minitest\"` for Minitest."
end
require "riteway"

module Riteway
  if defined?(ADAPTER)
    raise LoadError, "riteway: adapter conflict — #{ADAPTER} already loaded. Only require one adapter (riteway/rspec or riteway/minitest)."
  end
  ADAPTER = :rspec

  # Internal — not part of the public API. Isolates RSpec matcher methods
  # so they don't pollute Riteway's module namespace.
  module RSpecBridge
    extend RSpec::Matchers
  end

  def self.assert(given:, should:, actual:, expected:)
    unless RSpec.respond_to?(:current_example) && RSpec.current_example
      raise "Riteway.assert must be called inside an it/specify block, not at describe-level. " \
            "Move this assertion inside an `it` block."
    end
    matcher = RSpecBridge.eq(expected)
    return if matcher.matches?(actual)
    raise RSpec::Expectations::ExpectationNotMetError,
      "Given #{given}: should #{should}\n#{matcher.failure_message}"
  end
end
