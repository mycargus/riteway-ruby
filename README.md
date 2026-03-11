# Riteway Ruby

[![CI](https://github.com/mycargus/riteway-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/mycargus/riteway-ruby/actions/workflows/ci.yml)

**The standard testing assertion style for AI Driven Development (AIDD) and software agents.**

This is the Ruby port of the [riteway JavaScript library](https://github.com/paralleldrive/riteway).

Riteway is a testing assertion style and philosophy which leads to simple, readable, helpful unit tests for humans and AI agents.

It lets you write better, more readable tests with a fraction of the code that traditional assertion frameworks would use.

Riteway is the AI-native way to build a modern test suite. It pairs well with RSpec, Claude Code, Cursor Agent, and more.

* **R**eadable
* **I**solated/**I**ntegrated
* **T**horough
* **E**xplicit

Riteway forces you to write **R**eadable, **I**solated, and **E**xplicit tests, because that's the only way you can use the API. It also makes it easier to be thorough by making test assertions so simple that you'll want to write more of them.

## Why Riteway for AI Driven Development?

Riteway's structured approach makes it ideal for AIDD:

**📖 Learn more:** [Better AI Driven Development with Test Driven Development](https://medium.com/effortless-programming/better-ai-driven-development-with-test-driven-development-d4849f67e339)

- **Clear requirements**: The given/should structure and 5-question framework help AI better understand exactly what to build
- **Readable by design**: Natural language descriptions make tests comprehensible to both humans and AI
- **Simple API**: Minimal surface area reduces AI confusion and hallucinations
- **Token efficient**: Concise syntax saves valuable context window space

## The 5 Questions Every Test Must Answer

There are [5 questions every unit test must answer](https://medium.com/javascript-scene/what-every-unit-test-needs-f6cd34d9836d). Riteway forces you to answer them.

1. What is the unit under test (module, function, class, whatever)?
2. What should it do? (Prose description)
3. What was the actual output?
4. What was the expected output?
5. How do you reproduce the failure?

## Installing

Add to your `Gemfile`:

```ruby
gem "riteway"
```

Or install directly:

```shell
gem install riteway
```

Then require the adapter for your test framework. Use one or the other — not both.

**RSpec** — require in `spec/spec_helper.rb`:

```ruby
require "riteway/rspec"
```

**Minitest** — require in `test/test_helper.rb`:

```ruby
require "minitest/autorun"
require "riteway/minitest"
```

Minitest ships with Ruby's standard library — no extra gem needed.

## Example Usage

```ruby
require "riteway/rspec"
require "riteway"

# A function to test
def sum(*args)
  args.each { |n| raise TypeError, "Not a number: #{n.inspect}" unless n.is_a?(Numeric) }
  args.reduce(0, :+)
end

RSpec.describe "sum()" do
  it "given no arguments, should return 0" do
    Riteway.assert(
      given: "no arguments",
      should: "return 0",
      actual: sum(),
      expected: 0
    )
  end

  it "given zero, should return the correct sum" do
    Riteway.assert(
      given: "zero",
      should: "return the correct sum",
      actual: sum(2, 0),
      expected: 2
    )
  end

  it "given negative numbers, should return the correct sum" do
    Riteway.assert(
      given: "negative numbers",
      should: "return the correct sum",
      actual: sum(1, -4),
      expected: -3
    )
  end

  it "given a non-numeric argument, should raise TypeError" do
    error = Riteway.attempt(method(:sum), 1, "NaN")

    Riteway.assert(
      given: "a non-numeric argument",
      should: "raise TypeError",
      actual: error.class,
      expected: TypeError
    )
  end
end
```

## Output

Riteway uses RSpec under the hood, so you get all of RSpec's output formats. The default format shows each test as a dot; use `--format documentation` for full prose output:

```shell
bundle exec rspec --format documentation
```

```
sum()
  given no arguments, should return 0
  given zero, should return the correct sum
  given negative numbers, should return the correct sum
  given a non-numeric argument, should raise TypeError

Finished in 0.00112 seconds
4 examples, 0 failures
```

When a test fails, the given/should context is always included in the error:

```
Given negative numbers: should return the correct sum
  expected: -3
       got: 0
```

## API

### `Riteway.assert`

```ruby
Riteway.assert(given:, should:, actual:, expected:) => void, raises
```

The core assertion. Takes keyword arguments and compares `actual` to `expected` using deep equality (`eq`). All four arguments are required — missing any raises Ruby's native `ArgumentError`.

`assert` uses RSpec's `eq` matcher, which handles deep comparison of arrays, hashes, and nested structures.

```ruby
Riteway.assert(
  given: "an array of numbers",
  should: "equal the expected array",
  actual: [1, 2, 3].map { |n| n * 2 },
  expected: [2, 4, 6]
)
```

### `Riteway.attempt`

```ruby
Riteway.attempt(callable, *args) => Error | Any
```

Execute a callable or block with the given arguments. Returns the error if one is raised, otherwise returns the result. Designed for testing error cases in your assertions. Supports positional args, keyword args, lambdas, procs, and blocks.

`attempt` catches `StandardError` and its subclasses (Ruby's default `rescue` behavior). Exceptions outside this hierarchy — `SystemExit`, `Interrupt`, `SignalException` — propagate normally.

```ruby
# Block form (most concise)
error = Riteway.attempt { Integer("not a number") }

# Lambda form
error = Riteway.attempt(-> { Integer("not a number") })

# Method reference with positional args
error = Riteway.attempt(method(:sum), 1, "NaN")

# Method reference with keyword args
result = Riteway.attempt(method(:create_user), name: "Alice", age: 30)

Riteway.assert(
  given: "a non-numeric string",
  should: "raise ArgumentError",
  actual: error.class,
  expected: ArgumentError
)
```

### `Riteway.count_keys`

```ruby
Riteway.count_keys(hash = {}) => Integer
```

Given a hash, return a count of its keys. Defaults to `{}` (returns `0`) when called with no arguments. Handy when you're adding new state to a hash keyed by ID and want to ensure the correct number of keys were added.

```ruby
Riteway.assert(
  given: "a hash with 3 keys",
  should: "return 3",
  actual: Riteway.count_keys({ a: 1, b: 2, c: 3 }),
  expected: 3
)
```

### `Riteway.match`

```ruby
Riteway.match(text) => ->(pattern) => String
```

Take some text to search and return a lambda which takes a pattern and returns the matched text, or `nil` if no match — consistent with Ruby's own `String#match`. The pattern can be a String or Regexp. String patterns are auto-escaped so regex meta-characters are treated as literals.

```ruby
contains = Riteway.match("<h1>Dialog Title</h1>")

Riteway.assert(
  given: "some text and a string pattern",
  should: "return the matched text",
  actual: contains.call("Dialog Title"),
  expected: "Dialog Title"
)

Riteway.assert(
  given: "some text and a regex pattern",
  should: "return the matched text",
  actual: contains.call(/\w+/),
  expected: "Dialog"
)

Riteway.assert(
  given: "a pattern that does not match",
  should: "return nil",
  actual: contains.call("not found"),
  expected: nil
)
```

You can also use `contains.("pattern")` or `contains["pattern"]` as shorthand for `.call`.

## Publishing

Publishing is manual only — run these commands yourself:

```sh
gem build riteway.gemspec
gem push riteway-*.gem
```

`rake release` is intentionally disabled to prevent automated publishing.

## License

MIT
