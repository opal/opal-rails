require 'opal/rspec/rake_task'

Opal::RSpec::RakeTask.new('opal:spec' => :environment) do |server|
  require 'tempfile'

  asset_paths = Opal.paths + Rails.configuration.assets.paths.to_a
  tempfile = Tempfile.new(['opal-rspec', '.js.rb'])

  server.sprockets.clear_paths
  asset_paths << File.dirname(tempfile.path)
  asset_paths << Rails.application.config.opal.spec_location
  server.main = File.basename(tempfile.path, '.js.rb')

  asset_paths.each { |path| server.append_path path }

  required_assets = ['opal']
  required_assets << 'opal-rspec-runner'

  asset_paths.each do |path|
    Dir["#{path}/spec/**_spec.js.{opal,rb}"].each do |spec|
      spec = spec[path.size+1..-1] # +1 is for the trailing slash
      required_assets << spec
    end
  end

  required_assets.each { |a| tempfile.puts "require #{a.inspect}" }
  tempfile.close
end
