require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task default: :spec
task i: %i[install:local clobber]

desc 'Run RSpec tests'
RSpec::Core::RakeTask.new
