# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

CLOBBER.include(
  'coverage/',
  'pkg/',
  'riteway-*.gem',
  'Gemfile.lock'
)

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test
