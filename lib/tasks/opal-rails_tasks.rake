require 'opal/rspec/rake_task'

Opal::RSpec::RakeTask.new('opal:spec' => :environment) do |server, task|
  task.pattern = ENV['PATTERN'] || (Rails.application.config.opal.spec_location+'/**/*_spec{,.js}.{rb,opal}')
  # not setting task.default_path here (see opal-rspec commit 0497dce5c8c5efa0d34dc917363c90aefaef12b8) because engine already does 'app.assets.append_path spec_location'
  Rails.application.assets.paths.each {|p| server.append_path p}
end
