# Riteway Ruby — Implementation Plan

## Overview

Port the [riteway](../riteway) JavaScript testing library to Ruby. The Ruby version provides the same core API — `assert`, `attempt`, `count_keys`, `match` — as an adapter for existing Ruby test frameworks.

## Source Reference

JavaScript library at `../riteway` (upstream: [paralleldrive/riteway](https://github.com/paralleldrive/riteway); source files: `source/riteway.js`, `source/match.js`).

## Current API

| Function | Signature | Description |
|----------|-----------|-------------|
| `Riteway.assert` | `(given:, should:, actual:, expected:)` | Required keyword args enforced by Ruby; raises `RSpec::Expectations::ExpectationNotMetError` (RSpec) or `Minitest::Assertion` (Minitest) with `"Given #{given}: should #{should}\n<diff>"` |
| `Riteway.attempt` | `(callable = nil, *args, **kwargs, &block)` | Calls callable or block with args/kwargs; returns the error if raised (`StandardError` only), otherwise returns the result. Raises `ArgumentError` for missing or non-callable input (guards are outside `rescue` scope). |
| `Riteway.count_keys` | `(hash = {})` | Returns `hash.keys.length`; raises `TypeError` for non-Hash input; defaults to `{}` (returns `0`) |
| `Riteway.match` | `(text)` | Returns a lambda `(pattern) => String\|nil`; raises `TypeError` for non-String `text`; lambda raises `TypeError` for non-String/non-Regexp pattern; returns matched text or `nil` on no match |

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

## Phase 5: UX Hardening III ✅ COMPLETE

Twelve issues surfaced from an engineer-perspective review, plus seven issues from a plan review. Grouped into 8 implementation steps, ordered by dependency (foundational changes first, docs last).

### Step 1: `match` input guards (Review Issues #1, #2)

**Files:** `lib/riteway/match.rb`, `spec/match_spec.rb`, `test/match_test.rb`

**Changes:**
- Add `TypeError` guard at top of `match(text)` for non-String input (nil, Integer, etc.)
- Add `TypeError` guard inside the returned lambda for nil/invalid pattern
- Add dogfooded tests for both cases in both test suites

Note: `Symbol#match` exists in Ruby 3.0+, but `match` is about searching rendered output / HTML strings. Rejecting Symbols is intentional narrowing — use `.to_s` if needed.

```ruby
# match.rb
def self.match(text)
  raise TypeError, "match expects a String, got #{text.class}" unless text.is_a?(String)
  ->(pattern) {
    raise TypeError, "pattern must be a String or Regexp, got #{pattern.class}" unless pattern.is_a?(String) || pattern.is_a?(Regexp)
    re = pattern.is_a?(String) ? Regexp.new(Regexp.escape(pattern)) : pattern
    matched = text.match(re)
    matched ? matched[0] : nil
  }
end
```

**ADR:** `013-match-input-guards.md` — Guards at creation time, not deferred to call time. String-only for text arg (Symbols rejected intentionally).

### Step 2: `attempt` guard restructuring (Review Issue #7, Plan Review #1)

**Files:** `lib/riteway.rb`, `spec/riteway_spec.rb`, `test/riteway_test.rb`

**Changes:**
- Add a `respond_to?(:call)` check after the existing nil guard
- **Behavior change:** Move both guards (nil and callable) outside `rescue` scope so they raise instead of being silently returned. Currently `Riteway.attempt` (no args) returns an `ArgumentError` object instead of raising — this is a bug where usage errors are swallowed by `rescue => e`
- Update existing tests: the nil-guard test currently wraps in an outer `attempt(-> { ... })` which will still work (outer attempt catches the now-propagating ArgumentError)
- Add dogfooded tests for non-callable input in both suites

```ruby
def self.attempt(callable = nil, *args, **kwargs, &block)
  fn = callable || block
  raise ArgumentError, "attempt requires a callable or a block" unless fn
  raise ArgumentError, "attempt expects a callable (responds to #call), got #{fn.class}" unless fn.respond_to?(:call)
  begin
    kwargs.empty? ? fn.call(*args) : fn.call(*args, **kwargs)
  rescue => e
    e
  end
end
```

**ADR:** `014-attempt-callable-guard.md` — Fail fast for usage errors (nil, non-callable). Guards are outside `rescue` scope so programmer mistakes propagate as real exceptions. Only errors from the callable itself are caught and returned. Updates ADR 005 scope.

### Step 3: RSpec namespace isolation + guard fix (Review Issues #3, #11)

**Files:** `lib/riteway/rspec.rb`

This step replaces the full `rspec.rb` file. Two changes combined because the guard fix (Issue #3) is a one-liner that would be immediately overwritten by the namespace isolation (Issue #11).

**Changes:**
- Replace `unless RSpec.current_example` with `unless RSpec.respond_to?(:current_example) && RSpec.current_example` — handles rspec-core not being loaded, called outside RSpec entirely, called at describe-level, called in `before(:all)`
- Move `extend RSpec::Matchers` from `Riteway` module to an internal module `Riteway::RSpecBridge`
- Reference `eq` through the internal module
- `RSpecBridge` is not part of the public API — documented in ADR

```ruby
require "rspec/expectations"
require "rspec/matchers"
require "riteway"

module Riteway
  if defined?(ADAPTER)
    raise LoadError, "riteway: adapter conflict — #{ADAPTER} already loaded. Only require one adapter (riteway/rspec or riteway/minitest)."
  end
  ADAPTER = :rspec

  # Internal — not part of the public API. Isolates RSpec matcher methods
  # so they don't pollute Riteway's module namespace.
  module RSpecBridge
    extend RSpec::Matchers
  end

  def self.assert(given:, should:, actual:, expected:)
    unless RSpec.respond_to?(:current_example) && RSpec.current_example
      raise "Riteway.assert must be called inside an it/specify block, not at describe-level. " \
            "Move this assertion inside an `it` block."
    end
    matcher = RSpecBridge.eq(expected)
    return if matcher.matches?(actual)
    raise RSpec::Expectations::ExpectationNotMetError,
      "Given #{given}: should #{should}\n#{matcher.failure_message}"
  end
end
```

**ADR:** `015-rspec-private-matchers.md` — Isolate RSpec matchers into `Riteway::RSpecBridge` (internal, not public API) to avoid namespace pollution on `Riteway`. Guard fix is a bugfix, no separate ADR needed.

### Step 4: Make `rspec-expectations` an optional dependency (Review Issue #8, Plan Review #2)

**Files:** `riteway.gemspec`, `lib/riteway/rspec.rb`

**Depends on:** Step 3 (modifies `rspec.rb` — must apply the `rescue LoadError` wrapper to the Step 3 output, not the original file).

**Changes:**
- Move `rspec-expectations` from `add_dependency` to `add_development_dependency`
- RSpec adapter still requires `rspec/expectations` — user must have `rspec` in their Gemfile
- Minitest-only users no longer pull in RSpec gems
- Add `rescue LoadError` wrapper in `riteway/rspec.rb` so Minitest-only users who accidentally require the wrong adapter get a helpful message instead of a raw `LoadError`

```ruby
# Top of riteway/rspec.rb (replaces the bare requires from Step 3)
begin
  require "rspec/expectations"
  require "rspec/matchers"
rescue LoadError
  raise LoadError,
    "riteway/rspec requires the 'rspec' gem. Add `gem \"rspec\"` to your Gemfile, " \
    "or use `require \"riteway/minitest\"` for Minitest."
end
```

**ADR:** `016-optional-rspec-dependency.md` — Core library has zero runtime dependencies; adapters document their framework requirement. Friendly LoadError message for wrong-adapter require.

### Step 5: Minitest failure-message test (Review Issue #12)

**Files:** `test/riteway_test.rb`

**Changes:**
- Add a test that intentionally fails an assertion and verifies the message includes `Given ... : should ...` context
- Closes the test coverage gap between RSpec (which tests failure message content) and Minitest (which didn't)

```ruby
it "given a failing assertion, should include given/should context" do
  error = Riteway.attempt(-> {
    Riteway.assert(given: "two values", should: "be equal", actual: 1, expected: 2)
  })
  Riteway.assert(
    given: "a failing assert",
    should: "include given/should in the message",
    actual: error.message.include?("Given two values: should be equal"),
    expected: true
  )
end
```

### Step 6: README fixes (Review Issues #4, #5, #6, #9, #10)

**Files:** `README.md`

**Changes:**

**6a. Fix redundant require (Issue #6):**
- Remove `require "riteway"` from the example usage section (line 77)

**6b. Fix `attempt` signature (Issue #9):**
- Change from `Riteway.attempt(callable, *args)` to `Riteway.attempt(callable = nil, *args, **kwargs, &block)`

**6c. Document `attempt` / Exception limitation (Issue #4):**
- Add note: `attempt` catches `StandardError` only; RSpec's `ExpectationNotMetError` inherits from `Exception` and propagates through

**6d. Document adapter output differences (Issue #5):**
- Add brief note that failure output format varies slightly between RSpec and Minitest

**6e. `count_keys` acknowledgement (Issue #10):**
- No code change; consider one-line README note that it's a convenience wrapper for readability

### Step 7: Update project documentation

**Files:** `CLAUDE.md`, `plans/PLAN.md`, `.claude/skills/review/references/library-map.md`

**Changes:**
- Update `CLAUDE.md` architecture notes to reflect `attempt` rescue scope change and new guards
- Update `Current API` table in `plans/PLAN.md` to reflect new guards on `match` and `attempt`
- Update `library-map.md` "Known Non-Obvious Behaviors" to reflect changes (e.g., remove `attempt` can't catch note if documented in README, add guard behaviors)
- Mark Phase 5 complete

### Implementation Order

| Step | What | Files Changed | Risk |
|------|------|---------------|------|
| 1 | `match` input guards | match.rb, match specs/tests | Low — additive guards |
| 2 | `attempt` guard restructuring | riteway.rb, specs/tests | Medium — behavior change (guards now raise) |
| 3 | RSpec namespace isolation + guard fix | rspec.rb (full replacement) | Medium — changes how `eq` is accessed |
| 4 | Optional rspec dependency | gemspec, rspec.rb (adds LoadError wrapper to Step 3 output) | Medium — changes install behavior |
| 5 | Minitest failure-message test | test/riteway_test.rb | Low — additive test |
| 6 | README fixes | README.md | Low — docs only |
| 7 | Update project docs | CLAUDE.md, PLAN.md, library-map.md | Low — docs only |

Steps 1 and 2 are independent and can be done in parallel. Steps 3 and 4 are sequential (Step 4 modifies `rspec.rb` from Step 3's output). Step 5 is independent. Steps 6 and 7 come last since they reference all other changes.

## Backlog

*No items in backlog.*
