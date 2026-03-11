# ADR-5: `attempt` Supports Both Callables and Blocks

**Context:** Ruby idiom favors blocks for inline code (`attempt { raise "oops" }`) but callables (lambdas/procs) are needed for pre-defined functions and passing arguments.

**Decision:** Accept `(callable = nil, *args, **kwargs, &block)`. Callable takes priority over block if both are given. Raises `ArgumentError` if neither is provided.

**Consequences:**
- `Riteway.attempt(my_lambda, arg1)` and `Riteway.attempt { risky_code }` both work.
- kwargs are forwarded correctly in Ruby 3+ (no implicit hash-to-kwargs conversion).
