# ADR-3: `attempt` Instead of `try`

**Context:** The JS library uses `Try`. Ruby's `Object#try` (Active Support) and `try` as a soft keyword in some contexts make it a poor name choice.

**Decision:** Name the function `attempt`. Same semantics: call a function, return the error if it raises, otherwise return the result.

**Consequences:**
- No name collision with Active Support or future Ruby reserved words.
- `attempt` communicates the same intent as `Try`.
