#!/usr/bin/env rake


# BUNDLER

require 'bundler/setup'
Bundler::GemHelper.install_tasks


# TEST

task(:use_test_env) { ENV['RAILS_ENV'] = 'test' }
task(:use_test_asset_dbg_off_env) { ENV['RAILS_ENV'] = 'test_asset_dbg_off' }
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :rspec_1
RSpec::Core::RakeTask.new :rspec_2

task :rspec => [:use_test_env,
                :rspec_1,
                :use_test_asset_dbg_off_env,
                :rspec_2]

require File.expand_path('../test_app/config/application', __FILE__)
TestApp::Application.load_tasks

task :default => [:rspec, 'opal:spec']
