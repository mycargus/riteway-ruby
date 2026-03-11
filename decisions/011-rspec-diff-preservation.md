# ADR-11: RSpec Failure Messages Preserve Diff Output

**Context:** Initially, `assert` used `expect(actual).to eq(expected)` which produces good diffs but generic messages. Using a custom failure message via `expect(...).to eq(...), message` suppresses RSpec's diff output.

**Decision:** Use the matcher directly: call `matcher.matches?(actual)`, then on failure raise `ExpectationNotMetError` with `"Given X: should Y\n#{matcher.failure_message}"`.

**Consequences:**
- Failure output shows both the descriptive `Given/should` context and the detailed expected/actual diff.
- Bypasses RSpec's `expect` DSL but uses the same underlying matcher, so equality semantics are identical.
