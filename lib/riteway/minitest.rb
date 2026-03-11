# frozen_string_literal: true

require "minitest"
require "riteway"

module Riteway
  if defined?(ADAPTER)
    raise LoadError,
          "riteway: adapter conflict — #{ADAPTER} already loaded. " \
          "Only require one adapter (riteway/rspec or riteway/minitest)."
  end

  ADAPTER = :minitest

  module MinitestLifecycle
    def before_setup
      super
      Thread.current[:riteway_minitest_context] = self
    end

    def after_teardown
      Thread.current[:riteway_minitest_context] = nil
      super
    end
  end

  def self.assert(given:, should:, actual:, expected:)
    ctx = Thread.current[:riteway_minitest_context]
    unless ctx
      raise "Riteway.assert must be called inside an it/test block. " \
            "Ensure `require \"riteway/minitest\"` is in your test_helper.rb " \
            "and that assert is only called from within a test context."
    end
    unless given.is_a?(String) && !given.empty?
      raise ArgumentError,
            "given: must be a non-empty String, got #{given.inspect}"
    end
    unless should.is_a?(String) && !should.empty?
      raise ArgumentError,
            "should: must be a non-empty String, got #{should.inspect}"
    end

    message = "Given #{given}: should #{should}"
    expected.nil? ? ctx.assert_nil(actual, message) : ctx.assert_equal(expected, actual, message)
    nil
  end
end

Minitest::Test.include Riteway::MinitestLifecycle
