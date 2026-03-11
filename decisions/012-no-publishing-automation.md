# ADR-12: No Publishing Automation

**Context:** Accidental gem publishes are irreversible — a version pushed to RubyGems cannot be re-used.

**Decision:** `Rakefile` does not include `bundler/gem_tasks` or `rake release`. Publishing is manual: `gem build && gem push`.

**Consequences:**
- No accidental publishes from CI or muscle memory.
- Explicit friction before every release is intentional.
