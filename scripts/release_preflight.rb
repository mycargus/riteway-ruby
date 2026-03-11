# frozen_string_literal: true

require "shellwords"

# Preflight checks for rake release. Uses an injectable git adapter so the
# checks can be tested without running real git commands.
module ReleasePreflight
  class Error < StandardError; end

  # Default adapter — runs real git commands.
  module Git
    def self.branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end

    def self.porcelain_status
      `git status --porcelain`
    end

    def self.upstream?
      `git rev-list @{u}..HEAD --count 2>/dev/null`
      $CHILD_STATUS.exitstatus.zero?
    end

    def self.commits_ahead
      `git rev-list @{u}..HEAD --count`.strip.to_i
    end

    def self.tag_list(tag)
      `git tag -l #{Shellwords.escape(tag)}`.strip
    end
  end

  def self.run!(tag:, git: Git)
    check_on_main!(git)
    check_clean_tree!(git)
    check_head_pushed!(git)
    check_tag_absent!(tag, git)
  end

  def self.check_on_main!(git)
    branch = git.branch
    raise Error, "Must release from main (currently on '#{branch}')." unless branch == "main"
  end

  def self.check_clean_tree!(git)
    raise Error, "Working tree is dirty. Commit or stash changes first." unless git.porcelain_status.empty?
  end

  def self.check_head_pushed!(git)
    raise Error, "No upstream tracking branch. Run: git push -u origin main" unless git.upstream?
    raise Error, "Unpushed commits exist. Run: git push origin main" unless git.commits_ahead.zero?
  end

  def self.check_tag_absent!(tag, git)
    raise Error, "Tag #{tag} already exists. Is version.rb up to date?" if git.tag_list(tag) == tag
  end
end
