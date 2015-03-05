require 'opal/rspec/rake_task'

def conf_spec_server server, close_tmp_file=true
  asset_paths = Opal.paths + Rails.configuration.assets.paths.to_a
  server.sprockets.clear_paths
  opal_rails_specs_location = File.join Rails.root, Rails.application.config.opal.spec_location

  asset_paths << opal_rails_specs_location

  asset_paths.each { |path| server.append_path path }
  server.main = 'sprockets_runner.rb.erb'
end

Opal::RSpec::RakeTask.new('opal:spec' => :environment) do |server|
  conf_spec_server server
end

PID_FILE = File.join(Rails.root, 'tmp/spec_server.pid')

namespace "opal:spec" do
  desc "Starts up a spec server on port 9999 until shut down"
  task "start_server" do
    include Rake::DSL if defined? Rake::DSL
    require 'rack'
    require 'webrick'
    PORT = 9998                 # to not conflict w/rake opal:spec
    server = fork do
      app = Opal::Server.new { |s|
        conf_spec_server s, false
        Rails.application.config.assets.paths.each { |path| puts "appending #{path}"; s.append_path path }
        # dunno why the above is empty, but is set in the Opal::RSpec::RakeTask
        s.append_path File.join(Rails.root, '/app/assets/javascripts')
        # added so it can find the runner
        s.append_path File.join(Gem::Specification.find_by_path("opal-rails").full_gem_path,
                                '/lib/assets/javascripts')
        s.main = 'sprockets_runner'

        s.debug = false
      }
      puts "Starting opal spec server"
      Rack::Server.start(:app => app, :Port => PORT, :AccessLog => [],
                         :Logger => WEBrick::Log.new("/tmp/opal-spec-server.log"))
    end

    File.open(PID_FILE, "w") { |f| f.puts server }
  end

  desc "Shuts down spec server if it's running"
  task "kill_server" do
    puts "Shutting down spec server"
    if File.exist?(PID_FILE)
      pid = File.read(PID_FILE).to_i
      puts "\tKilling pid = #{pid}"
      Process.kill(:SIGINT, pid.to_i) if pid
      File.delete(PID_FILE)
    end
  end

end
