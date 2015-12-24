# This file is used by Rack-based servers to start the application.

require 'bundler/setup'
require 'rails'
rails_version = Rails::VERSION::MAJOR
ENV["RAILS_ENV"] = "test"
ENV['DATABASE_URL'] = 'sqlite3::memory:'
require_relative "test_apps/rails#{rails_version}"

run RailsApp::Application
