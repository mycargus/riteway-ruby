# frozen_string_literal: true

module Riteway
  # Returns a lambda that searches text for a pattern (String or Regexp).
  # Returns the matched text on success, or nil if no match — consistent with
  # Ruby's String#match which also returns nil on no match.
  def self.match(text)
    raise TypeError, "match expects a String, got #{text.class}" unless text.is_a?(String)

    ->(pattern) {
      unless pattern.is_a?(String) || pattern.is_a?(Regexp)
        raise TypeError,
              "pattern must be a String or Regexp, got #{pattern.class}"
      end
      raise ArgumentError, "pattern must not be empty" if pattern.is_a?(String) && pattern.empty?

      re = pattern.is_a?(String) ? Regexp.new(Regexp.escape(pattern)) : pattern
      matched = text.match(re)
      matched ? matched[0] : nil
    }
  end
end
