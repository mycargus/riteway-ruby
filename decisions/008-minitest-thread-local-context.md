# ADR-8: Minitest Adapter Uses Thread-Local Test Context

**Context:** Minitest's `assert_equal` is an instance method on the running test object. `Riteway.assert` is a module-level method with no direct access to the test instance. RSpec doesn't have this problem because its matchers are designed as standalone objects.

**Decision:** `MinitestLifecycle` module hooks into `before_setup`/`after_teardown` to store the test instance in `Thread.current[:riteway_minitest_context]`. `Riteway.assert` reads this thread-local to delegate to the test instance's assertion methods.

**Consequences:**
- `assert_equal`/`assert_nil` are called on the real test instance, so Minitest's assertion counter increments correctly (shows `17 assertions` instead of `0`).
- Thread-safe — each test thread gets its own context.
- Calling `assert` outside a test block raises a descriptive error instead of a `NoMethodError` on `nil`.
