require 'opal/rspec/rake_task'

Opal::RSpec::RakeTask.new('opal:spec' => :environment) do |server, task|
  task.pattern = ENV['PATTERN'] || (Rails.application.config.opal.spec_location+'/**/*_spec{,.js}.{rb,opal}')
  Rails.application.assets.paths.each {|p| server.append_path p}
end
