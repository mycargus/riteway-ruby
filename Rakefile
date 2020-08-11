# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

CLOBBER.include(
  'coverage/',
  'pkg/',
  'riteway-*.gem',
  'Gemfile.lock'
)

RuboCop::RakeTask.new(:lint) do |t|
  t.requires << 'rubocop-minitest'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test
