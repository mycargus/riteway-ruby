require_relative "riteway/match"

module Riteway
  # Calls callable (or block) with given args. Returns the error if raised,
  # otherwise returns the result. Catches StandardError and subclasses only —
  # SystemExit, Interrupt, SignalException, etc. propagate normally.
  def self.attempt(callable = nil, *args, **kwargs, &block)
    fn = callable || block
    raise ArgumentError, "attempt requires a callable or a block" unless fn
    kwargs.empty? ? fn.call(*args) : fn.call(*args, **kwargs)
  rescue => e
    e
  end

  def self.count_keys(hash = {})
    raise TypeError, "count_keys expects a Hash, got #{hash.class}" unless hash.is_a?(Hash)
    hash.keys.length
  end
end
