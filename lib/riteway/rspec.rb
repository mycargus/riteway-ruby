require "rspec/expectations"
require "rspec/matchers"
require "riteway"

module Riteway
  if defined?(ADAPTER)
    raise LoadError, "riteway: adapter conflict — #{ADAPTER} already loaded. Only require one adapter (riteway/rspec or riteway/minitest)."
  end
  ADAPTER = :rspec

  extend RSpec::Matchers

  def self.assert(given:, should:, actual:, expected:)
    unless RSpec.current_example
      raise "Riteway.assert must be called inside an it/specify block, not at describe-level. " \
            "Move this assertion inside an `it` block."
    end
    matcher = eq(expected)
    return if matcher.matches?(actual)
    raise RSpec::Expectations::ExpectationNotMetError,
      "Given #{given}: should #{should}\n#{matcher.failure_message}"
  end
end
