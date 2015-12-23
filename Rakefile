#!/usr/bin/env rake


# BUNDLER

require 'bundler/setup'
Bundler::GemHelper.install_tasks


# TEST

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :rspec


require File.expand_path('../test_app/config/application', __FILE__)
TestApp::Application.load_tasks

task :default => [:rspec]
