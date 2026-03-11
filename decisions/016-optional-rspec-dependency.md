# ADR 016: rspec-expectations is an optional (development) dependency

## Status

Accepted

## Context

`rspec-expectations` was declared as a runtime `add_dependency` in the gemspec. This forced all users — including Minitest-only users — to install RSpec gems when they installed the `riteway` gem. Minitest ships with Ruby's standard library and has no external gem requirement.

## Decision

Move `rspec-expectations` from `add_dependency` to `add_development_dependency`. The core library (`lib/riteway.rb`, `lib/riteway/match.rb`) has zero runtime dependencies. The RSpec adapter (`lib/riteway/rspec.rb`) requires `rspec/expectations` at require-time and is only used by projects that already have `rspec` in their Gemfile.

Add a `rescue LoadError` wrapper in `riteway/rspec.rb` so users who accidentally `require "riteway/rspec"` without the `rspec` gem get a helpful, actionable error message instead of a raw `LoadError`.

## Consequences

- Minitest-only users install zero extra gems.
- RSpec users must have `gem "rspec"` in their Gemfile (they already do if they use RSpec).
- Wrong-adapter require produces a friendly error: `"riteway/rspec requires the 'rspec' gem. Add gem \"rspec\" to your Gemfile, or use require \"riteway/minitest\" for Minitest."`
