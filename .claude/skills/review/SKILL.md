---
name: review
description: This skill should be used when asked to review riteway-ruby from an engineer's perspective, "think like a user of this library", "look for UX issues", "find edge cases", "check for pitfalls", "review the API", "look for failure modes", or "improve UX". Performs a systematic engineer-perspective review of the riteway-ruby library, identifying poor UX, edge cases, failure modes, and improvements.
version: 0.2.0
---

# Riteway Ruby — Engineer Perspective Review

Perform a systematic review of riteway-ruby from the perspective of an engineer who is using it — not building it. The goal is to find friction, surprises, and places where the library could make it easier to do the right thing and harder to do the wrong thing.

## Mindset

Think like an engineer encountering this library for the first time, or using it daily on a real project. Ask at every step:

- What would I assume this does?
- What would actually happen?
- Would I be confused, surprised, or blocked?
- Is this easy to use correctly and hard to use incorrectly?

## Review Process

### Step 1: Read the source files

Read all four library files before forming opinions. Assumptions about implementation details are the most common source of missed issues.

Files to read (see `references/library-map.md` for the full map):
- `lib/riteway.rb`
- `lib/riteway/rspec.rb`
- `lib/riteway/minitest.rb`
- `lib/riteway/match.rb`

### Step 2: Run edge case experiments with subagents

Do NOT mentally simulate edge cases — actually run them. Use the Agent tool to spawn parallel subagents that execute throwaway Ruby scripts to verify behavior. This catches real issues that mental simulation misses (e.g., return value differences between adapters, unexpected empty-string handling).

**Launch these experiment groups in parallel using subagents:**

**Subagent A — Failure message formats:** Write temp spec/test files that trigger assertion failures and capture the actual output from both RSpec and Minitest. Compare the message format, backtrace location, and diff content side-by-side.

```
# Example experiments for the subagent:
# 1. Simple value mismatch (string, integer, nil)
# 2. Complex object mismatch (hash, array, nested)
# 3. Verify backtrace first line — library code vs user code?
# 4. Check assert return value on success (nil? true? something else?)
```

**Subagent B — Input boundary experiments:** Run scripts that test boundary inputs across all public methods:

```
# Example experiments for the subagent:
# 1. assert with nil/empty/non-string given: and should:
# 2. match("").call("anything"), match("hello").call("")
# 3. count_keys with nil, [], "string", nested hashes
# 4. attempt with Proc vs lambda, mixed positional + keyword args
# 5. attempt { block } with args — does it error or silently ignore?
```

**Subagent C — Adapter setup experiments:** Test require-time behavior:

```
# Example experiments for the subagent:
# 1. Require both adapters — error message quality?
# 2. Call assert outside it/test block — error message quality?
# 3. Minitest class-style (Minitest::Test) vs spec-style (describe)
# 4. assert inside before/after hooks
```

Each subagent should:
- Write temp files to `/tmp/` for experiments
- Run them with `bundle exec ruby` or `bundle exec rspec`
- Capture and report the actual output
- Note any surprises vs expected behavior

### Step 3: Walk through the API surface

For each public method, consider it from the user's perspective. Use the actual experiment results from Step 2 — do not guess.

**assert** — What does the failure message look like? Does it include both the given/should context AND the diff? Can it be called in the wrong place? What do missing kwargs look like? Are given/should validated?

**attempt** — Can I pass a block? kwargs? What errors does it catch vs let through? What happens with no arguments?

**count_keys** — What happens with nil? Non-hash types? Is the error clear?

**match** — What does the returned lambda look like to the user? What does no-match return? What about empty strings?

### Step 4: Check symmetry between adapters

Using the experiment results, compare the two adapters on:
- Failure message format (labels, punctuation, indentation)
- Return values on success
- Backtrace presentation
- Context-guard error messages
- Behavior with nil expected values

### Step 5: Use the review checklist

Work through `references/review-checklist.md` systematically. Each section covers a category of issues. Mark items that surface real problems. Cross-reference with experiment results.

### Step 6: Score and report

Rate each issue found by:
- **Severity**: Critical / Significant / Moderate / Minor / Polish
- **Category**: API ergonomics / Error messages / Setup / Documentation / Adapter symmetry
- **Fix direction**: What would make this better?

Organize the report with the highest-severity issues first. Include specific code examples that reproduce each issue where possible. Include the actual output from experiments — not paraphrased versions.

## What Good Output Looks Like

A good review surfaces concrete, specific issues — not vague observations. Each issue should include:

1. A specific scenario that triggers it
2. What the user expects
3. What actually happens (with actual output from experiments)
4. Why it matters (severity)
5. A suggested improvement

**Example of a good finding:**
> **[Significant] `attempt` silently ignores kwargs in Ruby 3**
> ```ruby
> error = Riteway.attempt(method(:create_user), name: "Alice")
> # => ArgumentError: wrong number of arguments (given 1, expected 0)
> ```
> The user expects kwargs to be forwarded. Instead, they're captured in `*args` and passed as a positional hash, which fails in Ruby 3's strict keyword separation. Fix: use `*args, **kwargs` and route `fn.call(*args, **kwargs)`.

**Example of a weak finding to avoid:**
> "The API could be more intuitive." — Too vague, no actionable direction.

## Additional Resources

- **`references/library-map.md`** — All source files, test files, public API, key design decisions, and known non-obvious behaviors
- **`references/review-checklist.md`** — Systematic checklist organized by category: API ergonomics, adapter setup, error messages, documentation accuracy, adapter symmetry, and real-world scenarios
