# Riteway Ruby — Implementation Plan

## Overview

Port the [riteway](../riteway) JavaScript testing library to Ruby. The Ruby version provides the same core API — `assert`, `attempt`, `count_keys`, `match` — as an adapter for existing Ruby test frameworks.

## Source Reference

JavaScript library at `../riteway` (upstream: [paralleldrive/riteway](https://github.com/paralleldrive/riteway); source files: `source/riteway.js`, `source/match.js`).

## Current API

| Function | Signature | Description |
|----------|-----------|-------------|
| `Riteway.assert` | `(given:, should:, actual:, expected:)` | Required keyword args enforced by Ruby; raises `RSpec::Expectations::ExpectationNotMetError` (RSpec) or `Minitest::Assertion` (Minitest) with `"Given #{given}: should #{should}\n<diff>"` |
| `Riteway.attempt` | `(callable = nil, *args, **kwargs, &block)` | Calls callable or block with args/kwargs; returns the error if raised (`StandardError` only), otherwise returns the result |
| `Riteway.count_keys` | `(hash = {})` | Returns `hash.keys.length`; raises `TypeError` for non-Hash input; defaults to `{}` (returns `0`) |
| `Riteway.match` | `(text)` | Returns a lambda `(pattern) => String\|nil`; returns matched text or `nil` on no match — consistent with Ruby's `String#match` |

## File Structure

```
riteway-ruby/
├── lib/
│   ├── riteway.rb              # attempt, count_keys; requires riteway/match
│   └── riteway/
│       ├── match.rb            # match() — curried text search
│       ├── rspec.rb            # RSpec adapter: assert, ADAPTER guard
│       └── minitest.rb         # Minitest adapter: assert, MinitestLifecycle
├── spec/
│   ├── spec_helper.rb          # require "riteway/rspec" (core auto-required)
│   ├── riteway_spec.rb         # RSpec tests (dogfooded)
│   └── match_spec.rb           # RSpec match tests (dogfooded)
├── test/
│   ├── test_helper.rb          # require "riteway/minitest" (core auto-required)
│   ├── riteway_test.rb         # Minitest tests (dogfooded)
│   └── match_test.rb           # Minitest match tests (dogfooded)
├── .claude/
│   └── skills/review/          # Engineer-perspective review skill
├── Gemfile
├── Gemfile.lock
├── Rakefile
├── riteway.gemspec             # gem name: "riteway"
├── CLAUDE.md
├── PLAN.md
└── .tool-versions              # ruby 3.4.7
```

## Phase 1: RSpec Adapter ✅ COMPLETE

Core API, file structure, dogfooded tests, gem infrastructure, README, CLAUDE.md.

### Design Decisions

- **Adapter pattern** — Mirrors the JS library's vitest/bun adapters. Phase 1 provides an RSpec adapter; Phase 2 adds Minitest.
- **Keyword arguments** — Required keyword args enforce the contract at the language level. Missing args raise Ruby's native `ArgumentError`.
- **Naming: `attempt` not `try`** — `try` is reserved in Ruby.
- **`count_keys` defaults to empty hash** — matches JS behavior where `countKeys()` returns `0`.
- **Dogfooded tests** — Tests use `Riteway.assert` for all assertions.
- **Deep equality** — Uses RSpec's `eq` matcher for deep comparison of arrays, hashes, nested structures.

### What Is NOT Ported (JS-specific)

- `createStream` — TAP output format
- `describe.only` / `describe.skip` — tape-specific; RSpec has its own mechanisms
- `describe` wrapper — RSpec's native `describe`/`it` used instead
- `render-component` — React/JSX specific
- CLI tool (`bin/riteway.js`) — JS-specific
- `end()` callback pattern — tape-specific async handling
- Vitest/Bun adapters — JS-specific
- Async `Try` (promise catching) — Ruby doesn't share JS's promise model; `attempt` handles synchronous `begin/rescue` only

## Phase 2: Minitest Adapter ✅ COMPLETE

- `lib/riteway/minitest.rb` — `assert` wired to Minitest's `assert_equal`/`assert_nil` via thread-local test context
- `test/` directory with Minitest::Spec style tests (dogfooded)

### Notes

- Minitest ships with Ruby's standard library — no extra gem needed for users
- In Ruby 3.4+, `minitest` is a bundled gem and must be declared in `Gemfile`/gemspec
- `assert_nil` is used when `expected` is `nil` (Minitest 6 requires this)
- Only one adapter should be required per project — `riteway/rspec` or `riteway/minitest`

## Phase 3: UX Hardening I ✅ COMPLETE

Six issues identified through dogfooding review:

1. **Adapters auto-require core** — `require "riteway/rspec"` alone now works; core auto-required by each adapter
2. **RSpec diff preserved on failure** — message now shows `Given X: should Y` + full expected/actual diff
3. **Minitest assertion count** — `17 assertions` instead of `0`; thread-local `MinitestLifecycle` hooks delegate to the running test instance
4. **Adapter conflict guard** — `ADAPTER` constant raises `LoadError` with clear message if both adapters required
5. **`attempt` rescue scope documented** — README explains `StandardError`-only behavior
6. **`match` lambda syntax** — `.call()` as primary syntax; shorthands noted

## Phase 4: UX Hardening II ✅ COMPLETE

Six additional issues identified through a second dogfooding review:

1. **`attempt` kwargs broken in Ruby 3** — Signature changed to `(callable = nil, *args, **kwargs, &block)`; routes through `fn.call(*args, **kwargs)` conditionally
2. **`attempt` block support** — `Riteway.attempt { raise "oops" }` now works; callable takes priority over block if both given
3. **RSpec out-of-context guard** — Raises with actionable message when called outside an `it` block (`RSpec.current_example` check)
4. **`match` returns `nil` on no match** — Changed from `""` to `nil`; consistent with Ruby's `String#match`; `nil` is falsy, `""` is not
5. **`count_keys(nil)` raises `TypeError`** — Clear message: `count_keys expects a Hash, got NilClass`
6. **Minitest context error is actionable** — Message now says what to check and where

## Backlog

*No items in backlog.*
