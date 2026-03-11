require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/testtask"
require "rubocop/rake_task"
require "shellwords"
require_relative "lib/riteway/version"
require_relative "scripts/release_preflight"

RSpec::Core::RakeTask.new(:rspec)

Rake::TestTask.new(:minitest) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

RuboCop::RakeTask.new(:lint)

task test: [:rspec, :minitest]

task default: [:lint, :test]

# Publishing must be done by a human — never by an AI agent.
# Override bundler's rake release: preflight checks, build, tag, push tag.
# Actual gem push happens in GitHub Actions when the tag is detected.
task :release do
  tag = "v#{Riteway::VERSION}"

  begin
    ReleasePreflight.run!(tag: tag)
  rescue ReleasePreflight::Error => e
    abort e.message
  end

  # Shared check: tag matches version.rb (same script used in CI)
  sh "ruby scripts/verify_release_tag.rb #{Shellwords.escape(tag)}"

  # Build locally as a dry run — catches gemspec/syntax errors before pushing the tag.
  # CI will rebuild from source; this copy is not used for publishing.
  Rake::Task[:build].invoke

  sh "git tag -a #{Shellwords.escape(tag)} -m #{Shellwords.escape("Release #{tag}")}"

  begin
    sh "git push origin #{Shellwords.escape(tag)}"
  rescue RuntimeError
    # Tag push failed — remove the local tag so the next attempt starts clean.
    system("git", "tag", "-d", tag)
    abort "Failed to push tag #{tag}. Local tag deleted. Try: bundle exec rake release"
  end

  # Push succeeded — discard the local build artifact. The canonical gem is
  # built and published by GitHub Actions.
  FileUtils.rm_rf("pkg")

  puts
  puts "#{tag} pushed. GitHub Actions will run tests and publish to RubyGems."
  puts "Monitor: https://github.com/mycargus/riteway-ruby/actions"
end
