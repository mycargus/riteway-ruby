---
name: riteway-ruby-review
description: This skill should be used when asked to review riteway-ruby from an engineer's perspective, "think like a user of this library", "look for UX issues", "find edge cases", "check for pitfalls", "review the API", "look for failure modes", or "improve UX". Performs a systematic engineer-perspective review of the riteway-ruby library, identifying poor UX, edge cases, failure modes, and improvements.
version: 0.1.0
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

### Step 2: Walk through the API surface

For each public method, consider it from the user's perspective:

**assert** — What does the failure message look like? Does it include both the given/should context AND the diff? Can it be called in the wrong place? What do missing kwargs look like?

**attempt** — Can I pass a block? kwargs? What errors does it catch vs let through? What happens with no arguments?

**count_keys** — What happens with nil? Non-hash types? Is the error clear?

**match** — What does the returned lambda look like to the user? What does no-match return? Is nil or "" more surprising?

### Step 3: Walk through adapter setup

Mentally simulate:
1. Adding the gem and running `bundle install`
2. Writing the require in spec_helper/test_helper
3. Writing a first test
4. Making it fail — reading the output
5. Loading two adapters by accident

### Step 4: Check symmetry between adapters

The RSpec and Minitest adapters should be interchangeable from the user's perspective. Identify any behavioral gaps, output format differences, or missing guards.

### Step 5: Use the review checklist

Work through `references/review-checklist.md` systematically. Each section covers a category of issues. Mark items that surface real problems.

### Step 6: Score and report

Rate each issue found by:
- **Severity**: Critical / Significant / Moderate / Minor / Polish
- **Category**: API ergonomics / Error messages / Setup / Documentation / Adapter symmetry
- **Fix direction**: What would make this better?

Organize the report with the highest-severity issues first. Include specific code examples that reproduce each issue where possible.

## What Good Output Looks Like

A good review surfaces concrete, specific issues — not vague observations. Each issue should include:

1. A specific scenario that triggers it
2. What the user expects
3. What actually happens
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
