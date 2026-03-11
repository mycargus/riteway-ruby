# ADR 014: attempt() callable guard (updates ADR 005)

## Status

Accepted

## Context

`attempt` already guarded against `nil` (no callable, no block), but a non-callable argument (e.g., an Integer) would silently fall through to `fn.call(...)` and raise `NoMethodError`, which would then be caught by `rescue => e` and returned as a result. This meant programmer mistakes (wrong argument type) were swallowed and returned rather than propagating as real exceptions.

Additionally, the `nil` guard itself was inside the `rescue` scope in the original implementation, so a missing-callable `ArgumentError` was also returned rather than raised.

## Decision

Add a `respond_to?(:call)` check after the nil guard:

```ruby
raise ArgumentError, "attempt expects a callable (responds to #call), got #{fn.class}" unless fn.respond_to?(:call)
```

Both guards (`unless fn` and `unless fn.respond_to?(:call)`) are placed outside the `begin/rescue` scope via an explicit `begin` block. This ensures programmer mistakes (wrong argument type) raise immediately and are not swallowed.

Only errors from the callable itself are caught and returned.

## Consequences

- `Riteway.attempt(42)` now raises `ArgumentError` instead of returning a `NoMethodError`.
- `Riteway.attempt` (no args) continues to raise `ArgumentError`, and now truly propagates rather than being caught.
- Existing tests that wrap `Riteway.attempt` (no args) in an outer `attempt(-> { ... })` still work — the outer attempt catches the now-propagating `ArgumentError`.
