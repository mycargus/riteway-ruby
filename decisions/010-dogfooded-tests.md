# ADR-10: Dogfooded Tests

**Context:** The JS riteway library tests itself with its own `assert`. This is both a validation technique (the library must be capable enough to test itself) and a demonstration of the API.

**Decision:** All specs and tests use `Riteway.assert` exclusively — no direct `expect`, `assert_equal`, or other framework assertions.

**Consequences:**
- Tests serve as living documentation of the API.
- Any breakage in `assert` immediately surfaces across the entire test suite.
- Forces the library to be expressive enough for real test scenarios.
