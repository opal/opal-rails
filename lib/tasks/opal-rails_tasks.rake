require 'opal/rspec/rake_task'

Opal::RSpec::RakeTask.new('opal:spec' => :environment) do |server|
  require 'opal/rails/spec_builder'
  pattern = ENV['PATTERN'] || nil

  builder = Opal::Rails::SpecBuilder.new(
    spec_location: Rails.application.config.opal.spec_location,
    sprockets: Rails.application.config.assets,
    pattern: pattern,
  )

  runner = builder.runner_pathname
  runner.dirname.mkpath
  runner.open('w') { |f| f << builder.main_code }

  server.sprockets.clear_paths
  builder.paths.each { |path| server.append_path path }

  main_name = runner.basename.to_s.gsub(/(\.js)?\.rb$/, '')

  # Sometimes seems that sprockets will need a moment to pickup the new file
  sleep 0.1 unless server.sprockets[main_name]

  server.main = main_name
end
