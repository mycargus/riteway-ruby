# ADR-4: `attempt` Catches `StandardError` Only

**Context:** Ruby's exception hierarchy distinguishes `StandardError` (application errors) from `Exception` (system-level: `SystemExit`, `Interrupt`, `SignalException`, `NoMemoryError`). The JS `Try` catches all errors, but JS doesn't have this distinction.

**Decision:** `rescue => e` catches `StandardError` and subclasses only. System-level exceptions propagate normally.

**Consequences:**
- `Ctrl-C`, `kill`, and out-of-memory conditions are never silently swallowed.
- Matches Ruby convention — bare `rescue` only catches `StandardError`.
- Users who need to catch broader exceptions can use their own `begin/rescue`.
