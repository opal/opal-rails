require 'capybara/rspec'

# unless ENV['CI']
  require 'capybara-webkit'
  Capybara.javascript_driver = :webkit
# end
