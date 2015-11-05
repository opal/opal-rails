require 'opal'
require 'opal-rspec'
at_exit { ::RSpec::Core::Runner.run(ARGV, $sdtin, $stdout) }
