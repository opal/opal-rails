require 'rails'
ENV["RAILS_ENV"] = "test"
ENV['DATABASE_URL'] = 'sqlite3::memory:'
require_relative "../../test_apps/rails"

