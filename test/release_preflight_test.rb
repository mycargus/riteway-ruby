# frozen_string_literal: true

require "test_helper"
require_relative "../scripts/release_preflight"

# Fake git adapter. All values default to a clean, releasable state.
ReleaseGitDouble = Struct.new(
  :branch, :status, :upstream, :commits_ahead_count, :tagged,
  keyword_init: true,
) do
  def porcelain_status = status
  def upstream? = upstream
  def commits_ahead = commits_ahead_count
  def tag_list(tag) = (tagged == tag ? tag : "")
end

VALID_RELEASE_GIT = ReleaseGitDouble.new(
  branch: "main",
  status: "",
  upstream: true,
  commits_ahead_count: 0,
  tagged: nil,
).freeze

describe "ReleasePreflight.run!()" do
  it "given valid git state, should not raise" do
    result = Riteway.attempt { ReleasePreflight.run!(tag: "v1.0.0", git: VALID_RELEASE_GIT) }

    Riteway.assert(
      given: "valid git state",
      should: "return nil without raising",
      actual: result,
      expected: nil,
    )
  end

  it "given non-main branch, should raise Error naming the branch" do
    git = ReleaseGitDouble.new(**VALID_RELEASE_GIT.to_h, branch: "feature/my-feature")
    error = Riteway.attempt { ReleasePreflight.run!(tag: "v1.0.0", git: git) }

    Riteway.assert(
      given: "non-main branch",
      should: "raise ReleasePreflight::Error",
      actual: error.class,
      expected: ReleasePreflight::Error,
    )
    Riteway.assert(
      given: "non-main branch",
      should: "include branch name in message",
      actual: Riteway.match(error.message).call("feature/my-feature"),
      expected: "feature/my-feature",
    )
  end

  it "given dirty working tree, should raise Error" do
    git = ReleaseGitDouble.new(**VALID_RELEASE_GIT.to_h, status: " M lib/riteway.rb")
    error = Riteway.attempt { ReleasePreflight.run!(tag: "v1.0.0", git: git) }

    Riteway.assert(
      given: "dirty working tree",
      should: "raise ReleasePreflight::Error",
      actual: error.class,
      expected: ReleasePreflight::Error,
    )
    Riteway.assert(
      given: "dirty working tree",
      should: "mention dirty in message",
      actual: Riteway.match(error.message).call("dirty"),
      expected: "dirty",
    )
  end

  it "given no upstream tracking branch, should raise Error" do
    git = ReleaseGitDouble.new(**VALID_RELEASE_GIT.to_h, upstream: false)
    error = Riteway.attempt { ReleasePreflight.run!(tag: "v1.0.0", git: git) }

    Riteway.assert(
      given: "no upstream tracking branch",
      should: "raise ReleasePreflight::Error",
      actual: error.class,
      expected: ReleasePreflight::Error,
    )
    Riteway.assert(
      given: "no upstream tracking branch",
      should: "mention upstream in message",
      actual: Riteway.match(error.message).call("upstream"),
      expected: "upstream",
    )
  end

  it "given unpushed commits, should raise Error" do
    git = ReleaseGitDouble.new(**VALID_RELEASE_GIT.to_h, commits_ahead_count: 2)
    error = Riteway.attempt { ReleasePreflight.run!(tag: "v1.0.0", git: git) }

    Riteway.assert(
      given: "unpushed commits",
      should: "raise ReleasePreflight::Error",
      actual: error.class,
      expected: ReleasePreflight::Error,
    )
    Riteway.assert(
      given: "unpushed commits",
      should: "mention git push in message",
      actual: Riteway.match(error.message).call("git push"),
      expected: "git push",
    )
  end

  it "given tag already exists, should raise Error naming the tag" do
    git = ReleaseGitDouble.new(**VALID_RELEASE_GIT.to_h, tagged: "v1.0.0")
    error = Riteway.attempt { ReleasePreflight.run!(tag: "v1.0.0", git: git) }

    Riteway.assert(
      given: "existing tag",
      should: "raise ReleasePreflight::Error",
      actual: error.class,
      expected: ReleasePreflight::Error,
    )
    Riteway.assert(
      given: "existing tag",
      should: "include tag name in message",
      actual: Riteway.match(error.message).call("v1.0.0"),
      expected: "v1.0.0",
    )
  end

  it "given a different existing tag, should not raise" do
    git = ReleaseGitDouble.new(**VALID_RELEASE_GIT.to_h, tagged: "v0.9.0")
    result = Riteway.attempt { ReleasePreflight.run!(tag: "v1.0.0", git: git) }

    Riteway.assert(
      given: "a different tag already exists",
      should: "not raise",
      actual: result,
      expected: nil,
    )
  end
end
