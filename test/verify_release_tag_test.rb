# frozen_string_literal: true

require "test_helper"
require "open3"
require_relative "../lib/riteway/version"

VERIFY_SCRIPT = File.expand_path("../scripts/verify_release_tag.rb", __dir__)

describe "scripts/verify_release_tag.rb" do
  def run_script(*args)
    stdout, stderr, status = Open3.capture3("ruby", VERIFY_SCRIPT, *args)
    { output: stdout + stderr, exit_code: status.exitstatus }
  end

  it "given a matching tag, should exit 0 and report matches" do
    result = run_script("v#{Riteway::VERSION}")

    Riteway.assert(
      given: "tag matching version.rb",
      should: "exit 0",
      actual: result[:exit_code],
      expected: 0,
    )
    Riteway.assert(
      given: "tag matching version.rb",
      should: "print 'matches'",
      actual: Riteway.match(result[:output]).call("matches"),
      expected: "matches",
    )
  end

  it "given a mismatched tag, should exit 1 and report the mismatch" do
    result = run_script("v99.99.99")

    Riteway.assert(
      given: "tag not matching version.rb",
      should: "exit 1",
      actual: result[:exit_code],
      expected: 1,
    )
    Riteway.assert(
      given: "tag not matching version.rb",
      should: "print 'does not match'",
      actual: Riteway.match(result[:output]).call("does not match"),
      expected: "does not match",
    )
  end

  it "given a tag without a v prefix, should exit 1" do
    result = run_script(Riteway::VERSION)

    Riteway.assert(
      given: "tag without v prefix (e.g. '0.1.0' instead of 'v0.1.0')",
      should: "exit 1",
      actual: result[:exit_code],
      expected: 1,
    )
    Riteway.assert(
      given: "tag without v prefix",
      should: "print 'must start with'",
      actual: Riteway.match(result[:output]).call("must start with"),
      expected: "must start with",
    )
  end

  it "given no argument, should exit 1 and print usage" do
    result = run_script

    Riteway.assert(
      given: "no argument",
      should: "exit 1",
      actual: result[:exit_code],
      expected: 1,
    )
    Riteway.assert(
      given: "no argument",
      should: "print Usage",
      actual: Riteway.match(result[:output]).call("Usage"),
      expected: "Usage",
    )
  end
end
