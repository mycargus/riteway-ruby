# Riteway Ruby — Library Map

## Source Files

| File | Responsibility |
|------|---------------|
| `lib/riteway.rb` | `attempt`, `count_keys`; requires match |
| `lib/riteway/match.rb` | `match()` — curried text search |
| `lib/riteway/rspec.rb` | RSpec adapter — `assert` wired to `eq` matcher |
| `lib/riteway/minitest.rb` | Minitest adapter — `assert` via thread-local test context |

## Test Files

| File | What it covers |
|------|---------------|
| `spec/spec_helper.rb` | RSpec setup |
| `spec/riteway_spec.rb` | assert, attempt, count_keys (dogfooded with RSpec) |
| `spec/match_spec.rb` | match (dogfooded with RSpec) |
| `test/test_helper.rb` | Minitest setup |
| `test/riteway_test.rb` | assert, attempt, count_keys (dogfooded with Minitest) |
| `test/match_test.rb` | match (dogfooded with Minitest) |

## Public API

```ruby
Riteway.assert(given:, should:, actual:, expected:)
Riteway.attempt(callable = nil, *args, **kwargs, &block)
Riteway.count_keys(hash = {})
Riteway.match(text) # => ->(pattern) { ... }
```

## Design Decisions

See `decisions/` — one ADR per file. Key entries: 001 (adapter pattern), 002 (keyword args), 004 (StandardError scope), 005 (callables + blocks), 006 (match nil), 007 (count_keys TypeError), 013 (match input guards), 014 (attempt callable guard), 015 (RSpec namespace isolation), 016 (optional rspec dependency).

## Known Non-Obvious Behaviors

- `attempt` cannot catch `RSpec::Expectations::ExpectationNotMetError` or `Minitest::Assertion` — both inherit from `Exception`, not `StandardError`
- `attempt` raises `ArgumentError` (propagates) for nil or non-callable input — these are programmer mistakes, not caught errors
- `ADAPTER` constant conflict fires at `require` time, before any test runs
- `match` lambda can be called with `.call()`, `.()`, or `[]` syntax
- `count_keys` raises `TypeError` for non-Hash input including `nil`
- Minitest reports assertion count correctly because `Riteway.assert` delegates to the test instance
