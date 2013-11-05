require 'jquery'

require 'opal'
require 'opal-rspec'
require 'opal-jquery'

Document.ready? do
  Opal::RSpec::Runner.new.run
end
