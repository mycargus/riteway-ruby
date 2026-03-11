# riteway-ruby

Ruby port of the [riteway JavaScript library](https://github.com/paralleldrive/riteway). RSpec adapter providing `assert`, `attempt`, `count_keys`, and `match`.

## Commands

```sh
bundle install                              # install dependencies
bundle exec rspec                           # run RSpec tests
bundle exec rspec --format documentation   # verbose RSpec output
bundle exec ruby -I test test/riteway_test.rb test/match_test.rb  # run Minitest tests
bundle exec rake                            # run both suites
```

## Key Files

- `lib/riteway.rb` — `attempt`, `count_keys`; requires `riteway/match`
- `lib/riteway/match.rb` — `match()` curried text search
- `lib/riteway/rspec.rb` — RSpec adapter; `assert` wired to `expect().to eq()`
- `lib/riteway/minitest.rb` — Minitest adapter; `assert` wired to `assert_equal`/`assert_nil`
- `spec/riteway_spec.rb` — RSpec tests for assert, attempt, count_keys (dogfooded)
- `spec/match_spec.rb` — RSpec tests for match (dogfooded)
- `test/riteway_test.rb` — Minitest tests (dogfooded, Minitest::Spec style)
- `test/match_test.rb` — Minitest tests for match (dogfooded)
- `plans/PLAN.md` — implementation plan and phase history
- `decisions/` — architectural decision records (ADRs), one per file

## Architecture

- **Adapter pattern** — `riteway/rspec` and `riteway/minitest` both implement `Riteway.assert`; require only one per project.
- **Required keyword args** — `assert(given:, should:, actual:, expected:)` enforces all four at the language level. Missing keys raise Ruby's native `ArgumentError`.
- **`attempt` not `try`** — `try` is reserved in Ruby.
- **Dogfooded tests** — all specs/tests use `Riteway.assert` for assertions.
- **Minitest nil handling** — Minitest 6 requires `assert_nil` instead of `assert_equal nil, ...`; the adapter handles this automatically.

## Constraints

- **Never publish automatically.** `rake release` is blocked. Publishing is manual: `gem build && gem push`.
- Tests must remain dogfooded — use `Riteway.assert` for all assertions in spec files.

## What Is NOT Ported from JS

- Async `Try` (promise catching) — Ruby has no equivalent
- `createStream` — TAP output format
- `describe` wrapper — use RSpec's native `describe`/`it`
- `describe.only` / `describe.skip` — use RSpec's `:focus` / `xdescribe`
- `render-component` — React/JSX specific
- CLI tool — JS specific
