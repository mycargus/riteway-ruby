# ADR 015: RSpec matchers isolated in Riteway::RSpecBridge

## Status

Accepted

## Context

`riteway/rspec.rb` used `extend RSpec::Matchers` directly on the `Riteway` module. This mixed all RSpec matcher methods (`eq`, `match`, `include`, `be`, etc.) into `Riteway`'s public namespace, potentially conflicting with Riteway's own `match` method and leaking RSpec internals into the public API.

Additionally, the out-of-context guard used `RSpec.current_example` directly, which raises `NoMethodError` if `rspec-core` is not loaded (e.g., in a standalone script that only loads `rspec-expectations`).

## Decision

1. Move `extend RSpec::Matchers` into an internal module `Riteway::RSpecBridge`. Reference `eq` through `RSpecBridge.eq(expected)`.
2. Guard the context check: `RSpec.respond_to?(:current_example) && RSpec.current_example` — handles rspec-core not loaded, describe-level calls, and `before(:all)` contexts.

`RSpecBridge` is intentionally not part of the public API.

## Consequences

- `Riteway.match` is unambiguously Riteway's own method — no RSpec `match` matcher leaking in.
- The out-of-context guard is robust against partially-loaded RSpec environments.
- No public API change.
