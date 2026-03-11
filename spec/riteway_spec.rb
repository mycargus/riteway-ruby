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
      Riteway.assert(
        given: "a failing assert",
        should: "include given/should in the message",
        actual: error.message.include?("Given two unequal values: should show context and diff"),
        expected: true
      )
      Riteway.assert(
        given: "a failing assert",
        should: "include the diff in the message",
        actual: error.message.include?("2") && error.message.include?("1"),
        expected: true
      )
    end
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
