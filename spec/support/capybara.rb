require 'capybara/rspec'

Capybara.javascript_driver = :selenium
# Specs should run much faster than this but in case Travis takes longer, provide some cushion
Capybara.default_wait_time = 10
