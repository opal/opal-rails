#= require opal_ujs
require 'opal-rspec'

Document.ready? do
  Opal::RSpec::Runner.new.run
end
