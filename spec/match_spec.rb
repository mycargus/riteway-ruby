require "spec_helper"

RSpec.describe "match()" do
  given = "some text to search and a pattern to match"
  should = "return the matched text"

  it "given a string pattern, should return the matched text" do
    text = "<h1>Dialog Title</h1>"
    pattern = "Dialog Title"
    contains = Riteway.match(text)

    Riteway.assert(
      given: given,
      should: should,
      actual: contains.call(pattern),
      expected: pattern
    )
  end

  it "given a regex pattern with digits and words, should return the matched text" do
    text = "<h1>There are 4 cats</h1>"
    contains = Riteway.match(text)

    Riteway.assert(
      given: "some text with digits",
      should: should,
      actual: contains.call(/\d+\s\w+/i),
      expected: "4 cats"
    )
  end

  it "given a string pattern with regex meta-characters, should return the matched text" do
    text = "<h1>Are there any cats?</h1>"
    pattern = "Are there any cats?"
    contains = Riteway.match(text)

    Riteway.assert(
      given: "some text that includes regex meta characters",
      should: should,
      actual: contains.call(pattern),
      expected: pattern
    )
  end

  it "given a pattern that does not match, should return nil" do
    text = "<h1>Hello World</h1>"
    contains = Riteway.match(text)

    Riteway.assert(
      given: "a pattern that does not match",
      should: "return nil",
      actual: contains.call("not found"),
      expected: nil
    )
  end
end
