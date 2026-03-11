# ADR-1: Adapter Pattern for Test Framework Support

**Context:** Ruby has two dominant test frameworks — RSpec and Minitest. The JS riteway library uses a similar adapter pattern (vitest/bun adapters) to plug into different test runners.

**Decision:** Implement `Riteway.assert` separately in each adapter (`riteway/rspec` and `riteway/minitest`). Core utilities (`attempt`, `count_keys`, `match`) live in the shared `riteway` module. Users require exactly one adapter per project.

**Consequences:**
- Each adapter defines `Riteway.assert` tailored to its framework's assertion/matcher API.
- An `ADAPTER` constant guard raises `LoadError` if both adapters are loaded, preventing silent conflicts.
- Core utilities are framework-agnostic and auto-required by each adapter.
