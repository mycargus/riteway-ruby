# Riteway Ruby — Review Checklist

Use this checklist systematically when reviewing riteway-ruby from an engineer's perspective.

**Important:** Do not just mentally simulate these items. Use subagents to run actual experiments for items marked with (experiment). Cross-reference actual output against expectations.

---

## 1. API Ergonomics

### assert
- [ ] Can a user accidentally call `assert` outside an `it`/`test` block? What happens? (experiment)
- [ ] Are keyword arg error messages clear enough to diagnose the problem without reading docs?
- [ ] Does the failure message include both given/should context AND the diff? (experiment — capture actual output from both adapters)
- [ ] Does `nil` vs non-nil `expected` behave consistently across adapters? (experiment)
- [ ] Are `given:` and `should:` validated as non-empty strings? What happens with nil, empty, or non-string values? (experiment)
- [ ] Does `assert` return the same value in both adapters? (experiment)

### attempt
- [ ] Can the user pass kwargs to the callable? (`method(:create_user), name: "Alice"`) (experiment)
- [ ] Can the user pass a block instead of a lambda? (`attempt { raise "oops" }`)
- [ ] Can the user pass mixed positional + keyword args? (experiment)
- [ ] What happens when neither callable nor block is provided?
- [ ] What happens when the callable is not actually callable (e.g. a string)?
- [ ] Does `attempt` catch the errors the user expects? (StandardError vs Exception)
- [ ] Are there errors `attempt` silently swallows that the user would want to see?
- [ ] Does `attempt` work with both Procs and lambdas? (experiment)

### count_keys
- [ ] What happens with `nil`? A string? An array? (experiment)
- [ ] Is the error message clear about what went wrong?
- [ ] Does it count only top-level keys for nested hashes? (experiment)
- [ ] Is `count_keys` actually useful, or does it just duplicate `hash.size`?

### match
- [ ] What does `nil` text return? Does it crash or handle gracefully? (experiment)
- [ ] What does `nil` pattern return? (experiment)
- [ ] What does empty-string pattern return? (experiment)
- [ ] What does empty-string text with any pattern return? (experiment)
- [ ] Is the return value (`nil` on no match) consistent with Ruby idioms?
- [ ] Is the `.call()` / `.()` / `[]` syntax documented clearly?
- [ ] Would a user intuitively know they need to call the returned lambda?

---

## 2. Adapter Setup

### Both Adapters
- [ ] Can a user forget `require "riteway/rspec"` and get a confusing error?
- [ ] Is the require path intuitive? (riteway/rspec, not riteway-rspec or riteway_rspec)
- [ ] What happens if both adapters are required? Is the error clear? (experiment)
- [ ] Does the adapter auto-require the core, or does the user need both lines?

### RSpec Adapter
- [ ] Is there a guard for calling `assert` outside an `it` block? (experiment)
- [ ] Does `extend RSpec::Matchers` pollute `Riteway`'s namespace visibly?
- [ ] Does the adapter play well with RSpec's built-in matchers used in the same file?
- [ ] Does the failure backtrace point to user code first, or library internals? (experiment)
- [ ] Is backtrace filtering documented for the user?

### Minitest Adapter
- [ ] Does assertion count appear correctly in output? (experiment)
- [ ] What happens in a `before` or `after` hook? (experiment)
- [ ] Does it work with `Minitest::Test` class-style AND `Minitest::Spec` describe-style? (experiment)
- [ ] Does `parallel_tests` or threaded execution cause issues?

---

## 3. Error Messages

For each error a user might encounter, ask:
- Is it obvious what went wrong?
- Is it obvious what to do next?
- Does it point to the right location (user code, not library internals)?

Key error paths to check:
- [ ] Missing keyword args to `assert`
- [ ] Empty or nil `given:`/`should:` values
- [ ] Calling `assert` outside a test context (both adapters)
- [ ] Loading two adapters
- [ ] Passing `nil` to `count_keys`
- [ ] `attempt` with no callable and no block
- [ ] A failing assertion — does the message include both context and diff? (experiment — capture exact output)
- [ ] Empty-string pattern passed to `match` lambda

---

## 4. Documentation vs Reality

- [ ] Does the README example code actually work as written? (experiment — copy-paste and run)
- [ ] Do `require` statements in the README match current file structure?
- [ ] Are the API signatures in the README accurate?
- [ ] Does the README explain what happens on failure (failure message format)?
- [ ] Is the `attempt` / `StandardError` limitation clearly documented?
- [ ] Is the `match` nil-return clearly documented?
- [ ] Does the gem name in `Installing` match the gemspec?
- [ ] Is RSpec backtrace filtering documented?

---

## 5. Symmetry Between Adapters

Both adapters should behave identically from the user's perspective:
- [ ] `assert` produces equivalent output format (experiment — compare side-by-side)
- [ ] `assert` returns the same value on success
- [ ] `assert` outside context raises with a clear, actionable message
- [ ] `given:`/`should:` validation behaves identically
- [ ] Both test files use identical test cases (no gaps in Minitest vs RSpec coverage)
- [ ] README installation section is symmetric and consistent

---

## 6. Make Right Things Easy, Wrong Things Hard

For each pattern below, assess difficulty (Easy / Medium / Hard / Impossible):

| Pattern | Should be | Assess |
|---------|-----------|--------|
| Write a passing assertion | Easy | |
| Write a failing assertion with full context | Easy | |
| Use `attempt` with a block | Easy | |
| Use `attempt` with kwargs | Easy | |
| Accidentally load two adapters | Impossible | |
| Call `assert` outside a test | Hard (caught with clear error) | |
| Lose the diff in a failure message | Impossible | |
| Forget required kwargs on `assert` | Hard (Ruby catches it) | |
| Pass wrong type to `count_keys` | Hard (TypeError raised) | |
| Pass empty given/should to `assert` | Hard (ArgumentError raised) | |
| Pass empty pattern to `match` | Hard (ArgumentError raised) | |

---

## 7. Real-World Scenarios

Walk through these scenarios end-to-end. **Actually run code for each** (via subagents) rather than mentally simulating:

### New engineer onboarding
1. Add `gem "riteway"` to Gemfile
2. Run `bundle install`
3. Add `require "riteway/rspec"` to spec_helper
4. Write first test using `Riteway.assert`
5. Make the test fail intentionally — is the output clear?

### Testing an error case
1. Write a method that raises
2. Use `Riteway.attempt { ... }` to capture the error
3. Assert on `.class` and `.message`
4. What if the method takes keyword args?

### Testing string content
1. Use `Riteway.match` to search rendered output
2. Assert on what was found
3. Assert that something was NOT found (nil return)

### Switching from RSpec to Minitest (or vice versa)
1. Remove one require, add the other
2. Move tests from `spec/` to `test/`
3. Are there any API differences to know about?
