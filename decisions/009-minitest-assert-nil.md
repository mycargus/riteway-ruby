# ADR-9: Minitest `assert_nil` for `nil` Expected Values

**Context:** Minitest 6 deprecated `assert_equal nil, actual` and requires `assert_nil(actual)` instead. This would cause deprecation warnings or failures if not handled.

**Decision:** The Minitest adapter checks `expected.nil?` and routes to `assert_nil` or `assert_equal` accordingly.

**Consequences:**
- No deprecation warnings with Minitest 6+.
- Transparent to users — `assert(expected: nil, ...)` just works.
