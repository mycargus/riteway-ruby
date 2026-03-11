require "spec_helper"

# A function to test — mirrors the JS test's `sum()` example
def sum(*args)
  args.each do |n|
    raise TypeError, "Not a number: #{n.inspect}" unless n.is_a?(Numeric)
  end
  args.reduce(0, :+)
end

def greet(name:)
  "Hello, #{name}!"
end

RSpec.describe "sum()" do
  should = "return the correct sum"

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
      should: should,
      actual: sum(2, 0),
      expected: 2
    )
  end

  it "given negative numbers, should return the correct sum" do
    Riteway.assert(
      given: "negative numbers",
      should: should,
      actual: sum(1, -4),
      expected: -3
    )
  end

  it "given a non-numeric arg, should raise TypeError" do
    error = Riteway.attempt(method(:sum), 1, "NaN")

    Riteway.assert(
      given: "a non-numeric argument",
      should: "raise TypeError",
      actual: error.class,
      expected: TypeError
    )

    Riteway.assert(
      given: "a non-numeric argument",
      should: "include the bad value in the message",
      actual: error.message,
      expected: 'Not a number: "NaN"'
    )
  end
end

RSpec.describe "assert()" do
  it "given a nil value, should not raise" do
    Riteway.assert(
      given: "a nil value",
      should: "not raise",
      actual: nil,
      expected: nil
    )
  end

  it "given an empty given string, should raise ArgumentError" do
    error = Riteway.attempt(
      -> { Riteway.assert(given: "", should: "y", actual: 1, expected: 1) }
    )
    Riteway.assert(
      given: "an empty given string",
      should: "raise ArgumentError",
      actual: error.class,
      expected: ArgumentError
    )
  end

  it "given a nil given value, should raise ArgumentError" do
    error = Riteway.attempt(
      -> { Riteway.assert(given: nil, should: "y", actual: 1, expected: 1) }
    )
    Riteway.assert(
      given: "a nil given value",
      should: "raise ArgumentError",
      actual: error.class,
      expected: ArgumentError
    )
  end

  it "given an empty should string, should raise ArgumentError" do
    error = Riteway.attempt(
      -> { Riteway.assert(given: "x", should: "", actual: 1, expected: 1) }
    )
    Riteway.assert(
      given: "an empty should string",
      should: "raise ArgumentError",
      actual: error.class,
      expected: ArgumentError
    )
  end

  it "given missing keyword args, should raise ArgumentError" do
    error = Riteway.attempt(
      -> { Riteway.assert(given: "x", should: "y") }
    )
    Riteway.assert(
      given: "missing keyword args",
      should: "raise ArgumentError",
      actual: error.class,
      expected: ArgumentError
    )
  end

  it "given a failing assertion, should include given/should context AND the diff" do
    # ExpectationNotMetError < Exception, not StandardError, so rescue directly
    begin
      Riteway.assert(
        given: "two unequal values",
        should: "show context and diff",
        actual: 1,
        expected: 2
      )
    rescue RSpec::Expectations::ExpectationNotMetError => error
      contains = Riteway.match(error.message)

      Riteway.assert(
        given: "a failing assert",
        should: "include given/should in the message",
        actual: contains.call("Given two unequal values: should show context and diff"),
        expected: "Given two unequal values: should show context and diff"
      )
      Riteway.assert(
        given: "a failing assert",
        should: "include the expected value in the diff",
        actual: contains.call(/expected:\s*2/i),
        expected: "expected: 2"
      )
      Riteway.assert(
        given: "a failing assert",
        should: "include the actual value in the diff",
        actual: contains.call(/got:\s*1/i),
        expected: "got: 1"
      )
    end
  end

  it "given assert called outside an it block, should raise RuntimeError" do
    allow(RSpec).to receive(:current_example).and_return(nil)
    error = Riteway.attempt(-> {
      Riteway.assert(given: "no context", should: "raise", actual: 1, expected: 1)
    })
    allow(RSpec).to receive(:current_example).and_call_original

    Riteway.assert(
      given: "assert called outside an it block",
      should: "raise RuntimeError",
      actual: error.class,
      expected: RuntimeError
    )
  end
end

RSpec.describe "attempt()" do
  it "given a callable that raises, should return the error" do
    error = StandardError.new("oops")
    Riteway.assert(
      given: "a callable that raises",
      should: "return the error",
      actual: Riteway.attempt(-> { raise error }),
      expected: error
    )
  end

  it "given a callable that succeeds, should return the result" do
    Riteway.assert(
      given: "a callable that succeeds",
      should: "return the result",
      actual: Riteway.attempt(->(x) { x * 2 }, 21),
      expected: 42
    )
  end

  it "given a block, should work as the callable" do
    Riteway.assert(
      given: "a block that succeeds",
      should: "return the result",
      actual: Riteway.attempt { 6 * 7 },
      expected: 42
    )
  end

  it "given a block that raises, should return the error" do
    Riteway.assert(
      given: "a block that raises",
      should: "return the error",
      actual: Riteway.attempt { raise ArgumentError, "bad input" }.class,
      expected: ArgumentError
    )
  end

  it "given keyword arguments, should pass them through to the callable" do
    Riteway.assert(
      given: "a method with keyword arguments",
      should: "return the result",
      actual: Riteway.attempt(method(:greet), name: "Alice"),
      expected: "Hello, Alice!"
    )
  end

  it "given no callable and no block, should raise ArgumentError" do
    error = Riteway.attempt(-> { Riteway.attempt })
    Riteway.assert(
      given: "no callable and no block",
      should: "raise ArgumentError",
      actual: error.class,
      expected: ArgumentError
    )
  end

  it "given a non-callable argument, should raise ArgumentError" do
    error = Riteway.attempt(-> { Riteway.attempt(42) })
    Riteway.assert(
      given: "a non-callable argument",
      should: "raise ArgumentError",
      actual: error.class,
      expected: ArgumentError
    )
  end

  it "given both a callable and a block, should raise ArgumentError" do
    error = Riteway.attempt(-> { Riteway.attempt(-> { 1 }) { 2 } })
    Riteway.assert(
      given: "both a callable and a block",
      should: "raise ArgumentError",
      actual: error.class,
      expected: ArgumentError
    )
  end
end

RSpec.describe "count_keys()" do
  it "given a hash, should return the number of keys" do
    Riteway.assert(
      given: "a hash with 3 keys",
      should: "return 3",
      actual: Riteway.count_keys({ a: "a", b: "b", c: "c" }),
      expected: 3
    )
  end

  it "given no arguments, should return 0" do
    Riteway.assert(
      given: "no arguments",
      should: "return 0",
      actual: Riteway.count_keys,
      expected: 0
    )
  end

  it "given nil, should raise TypeError" do
    error = Riteway.attempt(-> { Riteway.count_keys(nil) })
    Riteway.assert(
      given: "nil",
      should: "raise TypeError",
      actual: error.class,
      expected: TypeError
    )
  end
end
