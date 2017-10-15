require 'capybara/rspec'

require 'capybara/poltergeist'


PoltergeistConsole = StringIO.new

RSpec.configure do |config|
  config.before { PoltergeistConsole.reopen }
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: PoltergeistConsole, timeout: 150)
end

Capybara.javascript_driver = :poltergeist
