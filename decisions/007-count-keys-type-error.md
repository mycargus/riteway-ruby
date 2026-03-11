# ADR-7: `count_keys` Raises `TypeError` for Non-Hash Input

**Context:** The JS version silently handles non-object input (returns 0 for `undefined`/`null` via default parameter). Ruby's duck typing could allow silent failures with `.keys` on non-Hash objects.

**Decision:** Raise `TypeError` with a descriptive message (`count_keys expects a Hash, got NilClass`) for non-Hash input. Default parameter `hash = {}` handles the no-argument case (returns 0).

**Consequences:**
- Catches bugs early — passing `nil` or a non-Hash is always a mistake.
- No-argument call returns `0`, matching JS behavior for `countKeys()`.
