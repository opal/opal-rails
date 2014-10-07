require 'opal'
require 'jquery'
require 'opal-rspec'
require 'opal-jquery'

Document.ready? do
  Opal::RSpec::Runner.new.run
end
