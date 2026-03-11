# ADR-2: Required Keyword Arguments for `assert`

**Context:** The JS riteway enforces `given`, `should`, `actual`, `expected` as the only way to write assertions. This forces descriptive test output and prevents meaningless test names.

**Decision:** Use Ruby's required keyword arguments: `assert(given:, should:, actual:, expected:)`. Missing keys raise Ruby's native `ArgumentError` (e.g., `missing keywords: actual, expected`).

**Consequences:**
- No custom validation code needed — Ruby enforces the contract at the language level.
- Error messages are clear and idiomatic.
- All four arguments are always present, matching the JS library's philosophy.
