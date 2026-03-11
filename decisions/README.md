# Architectural Decision Records

Decisions made during riteway-ruby development, with context and rationale.

| # | Decision | File |
|---|----------|------|
| 1 | Adapter pattern for test framework support | [001](001-adapter-pattern.md) |
| 2 | Required keyword arguments for `assert` | [002](002-required-keyword-arguments.md) |
| 3 | `attempt` instead of `try` | [003](003-attempt-not-try.md) |
| 4 | `attempt` catches `StandardError` only | [004](004-standard-error-only.md) |
| 5 | `attempt` supports both callables and blocks | [005](005-attempt-callables-and-blocks.md) |
| 6 | `match` returns `nil` on no match | [006](006-match-returns-nil.md) |
| 7 | `count_keys` raises `TypeError` for non-Hash | [007](007-count-keys-type-error.md) |
| 8 | Minitest thread-local test context | [008](008-minitest-thread-local-context.md) |
| 9 | Minitest `assert_nil` for `nil` values | [009](009-minitest-assert-nil.md) |
| 10 | Dogfooded tests | [010](010-dogfooded-tests.md) |
| 11 | RSpec failure messages preserve diff output | [011](011-rspec-diff-preservation.md) |
| 12 | No publishing automation | [012](012-no-publishing-automation.md) |
