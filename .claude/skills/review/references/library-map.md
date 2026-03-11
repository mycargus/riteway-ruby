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

## Key Design Decisions

- Required keyword args on `assert` — enforced by Ruby, raises `ArgumentError`
- `attempt` accepts callable OR block; catches `StandardError` only
- `match` returns `nil` on no match (consistent with `String#match`)
- RSpec adapter: raises `RSpec::Expectations::ExpectationNotMetError` (subclass of `Exception`, NOT `StandardError`)
- Minitest adapter: uses thread-local `Thread.current[:riteway_minitest_context]` to access running test instance
- Both adapters guard against use outside a test context
- `ADAPTER` constant prevents loading two adapters simultaneously

## Known Non-Obvious Behaviors

- `attempt` cannot catch `RSpec::Expectations::ExpectationNotMetError` — it inherits from `Exception`
- `ADAPTER` constant conflict fires at `require` time, before any test runs
- `match` lambda can be called with `.call()`, `.()`, or `[]` syntax
- `count_keys` raises `TypeError` for non-Hash input including `nil`
- Minitest reports assertion count correctly because `Riteway.assert` delegates to the test instance
