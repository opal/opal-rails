require 'opal/rspec/rake_task'

Opal::RSpec::RakeTask.new('opal:spec' => :environment) do |server|
  require 'opal/rails/spec_builder'
  pattern = ENV['PATTERN'] || nil

  builder = Opal::Rails::SpecBuilder.new(
    spec_location: Rails.application.config.opal.spec_location,
    sprockets: Rails.application.config.assets,
    pattern: pattern,
  )

  server.sprockets.clear_paths
  builder.paths.each { |path| server.append_path path }

  # require 'tempfile'
  # tempfile = Tempfile.new(['opal-rspec', '.js.rb'])
  # tempfile.puts builder.main_code
  # tempfile.close
  # server.main = File.basename(tempfile.path, '.js.rb')
  # server.append_path File.dirname(tempfile.path)

  spec_file = Rails.root.join('tmp/opal_spec.rb')
  server.append_path spec_file.dirname.to_s
  spec_file.open('w') { |f| f << builder.main_code }
  main = spec_file.basename.to_s.gsub(/\.rb$/, '')
  server.main = main
end
