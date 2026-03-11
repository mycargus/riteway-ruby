# frozen_string_literal: true

require_relative "riteway/version"
require_relative "riteway/match"

module Riteway
  def self.assert(**)
    raise "Riteway.assert requires an adapter. " \
          "Add `require \"riteway/rspec\"` or `require \"riteway/minitest\"` to your test helper."
  end

  # Calls callable (or block) with given args. Returns the error if raised,
  # otherwise returns the result. Catches StandardError and subclasses only —
  # SystemExit, Interrupt, SignalException, etc. propagate normally.
  def self.attempt(callable = nil, *args, **kwargs, &block)
    raise ArgumentError, "attempt accepts a callable or a block, not both" if callable && block

    fn = callable || block
    raise ArgumentError, "attempt requires a callable or a block" unless fn
    raise ArgumentError, "attempt expects a callable (responds to #call), got #{fn.class}" unless fn.respond_to?(:call)

    begin
      kwargs.empty? ? fn.call(*args) : fn.call(*args, **kwargs)
    rescue => error
      error
    end
  end

  def self.count_keys(hash = {})
    raise TypeError, "count_keys expects a Hash, got #{hash.class}" unless hash.is_a?(Hash)

    hash.keys.length
  end
end
