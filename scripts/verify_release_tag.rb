# frozen_string_literal: true

# Verify that a version tag matches lib/riteway/version.rb.
# Usage: ruby scripts/verify_release_tag.rb <tag>   (e.g. v0.1.0)
# Runs locally (from rake release) and in CI (from the release workflow).

require_relative "../lib/riteway/version"

tag = ARGV.first or abort "Usage: #{$PROGRAM_NAME} <tag>"

abort "ERROR: tag '#{tag}' must start with 'v' (e.g. v#{Riteway::VERSION})" unless tag.start_with?("v")

tag_version = tag.delete_prefix("v")

unless tag_version == Riteway::VERSION
  abort "ERROR: tag '#{tag}' does not match lib/riteway/version.rb (#{Riteway::VERSION})"
end

puts "Tag #{tag} matches lib/riteway/version.rb (#{Riteway::VERSION})"
