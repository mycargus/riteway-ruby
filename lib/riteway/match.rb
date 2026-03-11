module Riteway
  # Returns a lambda that searches text for a pattern (String or Regexp).
  # Returns the matched text on success, or nil if no match — consistent with
  # Ruby's String#match which also returns nil on no match.
  def self.match(text)
    ->(pattern) {
      re = pattern.is_a?(String) ? Regexp.new(Regexp.escape(pattern)) : pattern
      matched = text.match(re)
      matched ? matched[0] : nil
    }
  end
end
