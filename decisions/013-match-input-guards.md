# ADR 013: match() input guards

## Status

Accepted

## Context

`match(text)` accepted any argument without validation. Passing a non-String (e.g., `nil`, `42`) would raise a cryptic `NoMethodError` from inside the lambda or at `.match()` call time. Similarly, passing an invalid pattern to the returned lambda (e.g., `nil`) produced a confusing error.

## Decision

Add explicit `TypeError` guards:

- At `match(text)` creation time: reject non-String input immediately with `"match expects a String, got #{text.class}"`
- Inside the returned lambda: reject patterns that are not String or Regexp with `"pattern must be a String or Regexp, got #{pattern.class}"`

Guards fire at the point of misuse rather than deferred to an internal call site.

## Consequences

- Non-String text raises immediately at `Riteway.match(...)` call, not lazily.
- `Symbol` is rejected intentionally — `match` is designed for searching rendered output/HTML strings; callers who have a Symbol should use `.to_s` explicitly.
- Clearer error messages for both misuse cases.
