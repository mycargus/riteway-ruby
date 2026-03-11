require "rspec/core/rake_task"
require "rake/testtask"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:rspec)

Rake::TestTask.new(:minitest) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

RuboCop::RakeTask.new(:lint)

task test: [:rspec, :minitest]

task default: [:lint, :test]

# Publishing must be done manually by a human — never automated.
# Override bundler's built-in release task to prevent accidental/automated pushes.
task :release do
  abort "Publishing must be done manually. Run: gem build riteway.gemspec && gem push riteway-ruby-*.gem"
end
