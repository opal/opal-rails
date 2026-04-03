#!/usr/bin/env rake


# BUNDLER

require 'bundler/setup'
Bundler::GemHelper.install_tasks


# TEST

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec:non_js') do |task|
  task.rspec_opts = '--tag ~js --tag ~e2e'
end

RSpec::Core::RakeTask.new('spec:js') do |task|
  task.rspec_opts = '--tag js'
end

RSpec::Core::RakeTask.new('spec:e2e') do |task|
  task.rspec_opts = '--tag e2e'
end

task spec: ['spec:non_js', 'spec:js']
task rspec: :spec

task default: :spec
