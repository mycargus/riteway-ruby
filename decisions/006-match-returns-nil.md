# ADR-6: `match` Returns `nil` on No Match (Not Empty String)

**Context:** The JS `match` returns `""` on no match. In Ruby, `""` is truthy, which means `if match(text).call(pattern)` would evaluate as true even on no match — a footgun.

**Decision:** Return `nil` on no match, consistent with Ruby's `String#match`.

**Consequences:**
- `match(text).call(pattern)` is falsy on no match, truthy on match — works naturally in conditionals.
- Departs from JS behavior, but follows Ruby's principle of least surprise.
