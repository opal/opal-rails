# frozen_string_literal: true

require 'open3'
require 'net/http'
require 'fileutils'
require 'tmpdir'
require 'pathname'
require 'timeout'

# End-to-end lifecycle test for opal-rails.
#
# Creates a fresh Rails app (no flags skipped), installs opal-rails,
# writes Opal code, and exercises the full development -> test -> production
# cycle.  Opal assets are never built explicitly; every build is triggered
# implicitly through opal:watch (via bin/dev), test:prepare (via rails test),
# or assets:precompile (via rails assets:precompile).
#
# Run with: bundle exec rspec spec/end_to_end/ --tag e2e
#
# Excluded from the default suite because it is slow (~60-90s).
RSpec.describe 'Full opal-rails lifecycle', :e2e do
  GEM_ROOT = Pathname(__dir__).join('../..').expand_path.freeze

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def run!(cmd, env: {}, chdir: @app_root.to_s, label: cmd.to_s, timeout: 120)
    full_env = {
      'BUNDLE_GEMFILE' => @app_root.join('Gemfile').to_s,
      'RAILS_ENV' => nil,
      'RACK_ENV' => nil
    }.merge(env)

    stdout, stderr, status = nil
    Timeout.timeout(timeout) do
      stdout, stderr, status = Open3.capture3(full_env, *Array(cmd), chdir: chdir.to_s)
    end

    unless status.success?
      raise "Command failed: #{label}\nExit: #{status.exitstatus}\n" \
            "STDOUT:\n#{stdout}\nSTDERR:\n#{stderr}"
    end

    stdout
  end

  def unbundled_run!(cmd, **kwargs)
    Bundler.with_unbundled_env do
      run!(cmd, **kwargs)
    end
  end

  def write_file(relative_path, content)
    path = @app_root.join(relative_path)
    path.dirname.mkpath
    path.write(content)
  end

  def read_file(relative_path)
    @app_root.join(relative_path).read
  end

  # Start the app with bin/dev (Foreman: web + opal:watch).
  # Spawns as a process group so we can kill the whole tree.
  def start_dev
    @port = find_available_port
    dev_env = {
      'BUNDLE_GEMFILE' => @app_root.join('Gemfile').to_s,
      'PORT' => @port.to_s,
      'RAILS_ENV' => 'development'
    }

    @app_root.join('log').mkpath

    Bundler.with_unbundled_env do
      @dev_pid = spawn(
        dev_env,
        'bin/dev',
        chdir: @app_root.to_s,
        pgroup: true,
        out: @app_root.join('log/dev_stdout.log').to_s,
        err: @app_root.join('log/dev_stderr.log').to_s
      )
    end

    wait_for_server!
    wait_for_opal_build!
  end

  # Start the app with bin/rails server (production mode).
  def start_server(env: 'production', port: nil)
    @port = port || find_available_port
    server_env = {
      'BUNDLE_GEMFILE' => @app_root.join('Gemfile').to_s,
      'RAILS_ENV' => env,
      'PORT' => @port.to_s,
      'SECRET_KEY_BASE' => 'test_secret_key_base_for_e2e_0123456789abcdef' * 2,
      'RAILS_SERVE_STATIC_FILES' => '1',
      'RAILS_LOG_TO_STDOUT' => '0'
    }

    @app_root.join('log').mkpath

    Bundler.with_unbundled_env do
      @dev_pid = spawn(
        server_env,
        'ruby', 'bin/rails', 'server', '-b', '127.0.0.1', '-p', @port.to_s,
        chdir: @app_root.to_s,
        pgroup: true,
        out: @app_root.join('log/server_stdout.log').to_s,
        err: @app_root.join('log/server_stderr.log').to_s
      )
    end

    wait_for_server!
  end

  def stop_dev
    return unless @dev_pid

    # Kill the entire process group (foreman + children)
    Process.kill('-TERM', @dev_pid)
    Process.waitpid(@dev_pid)
    @dev_pid = nil
  rescue Errno::ESRCH, Errno::ECHILD
    @dev_pid = nil
  end

  alias_method :stop_server, :stop_dev

  def wait_for_server!(timeout: 60)
    deadline = Time.now + timeout
    loop do
      Net::HTTP.get(URI("http://127.0.0.1:#{@port}/"))
      return
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Net::ReadTimeout, EOFError
      raise "Server did not start within #{timeout}s" if Time.now > deadline

      sleep 0.5
    end
  end

  # Wait for opal:watch to produce the initial build.
  def wait_for_opal_build!(timeout: 60)
    deadline = Time.now + timeout
    js_path = @app_root.join('app/assets/builds/application.js')
    loop do
      return if js_path.exist? && js_path.size > 0
      raise "opal:watch did not produce application.js within #{timeout}s" if Time.now > deadline

      sleep 0.5
    end
  end

  # Wait for the built JS to contain the expected content (watch rebuild).
  def wait_for_js_content!(marker, timeout: 30)
    deadline = Time.now + timeout
    js_path = @app_root.join('app/assets/builds/application.js')
    loop do
      if js_path.exist? && js_path.read.include?(marker)
        # Give server a moment to pick up the new file
        sleep 0.5
        return
      end
      raise "Built JS did not contain '#{marker}' within #{timeout}s" if Time.now > deadline

      sleep 0.5
    end
  end

  def http_get(path = '/')
    uri = URI("http://127.0.0.1:#{@port}#{path}")
    Net::HTTP.start(uri.host, uri.port, read_timeout: 10) do |http|
      response = http.get(uri.path)
      response = http.get(URI(response['location']).path) if response.is_a?(Net::HTTPRedirection)
      response
    end
  end

  def find_available_port
    server = TCPServer.new('127.0.0.1', 0)
    port = server.addr[1]
    server.close
    port
  end

  # Fetch the HTML page, extract JS asset URLs, fetch each, and return
  # the concatenation of all JS bodies.
  def fetch_js_content(path = '/')
    html = http_get(path).body
    js_urls = html.scan(/src="([^"]*\.js[^"]*)"/).flatten
    js_urls.map { |url| http_get(url).body }.join("\n")
  end

  # ---------------------------------------------------------------------------
  # Setup / Teardown
  # ---------------------------------------------------------------------------

  around do |example|
    Dir.mktmpdir('opal_e2e_') do |dir|
      @app_root = Pathname(dir).join('testapp')
      example.run
    end
  ensure
    stop_dev
  end

  # ---------------------------------------------------------------------------
  # The test
  # ---------------------------------------------------------------------------

  it 'exercises the full development, test, and production lifecycle' do
    # -----------------------------------------------------------------------
    # Phase 1: Create a fresh Rails application (no --skip flags)
    # -----------------------------------------------------------------------
    Bundler.with_unbundled_env do
      run!(
        ['rails', 'new', @app_root.to_s, '--skip-bundle', '--skip-git'],
        chdir: Dir.tmpdir,
        label: 'rails new'
      )
    end
    expect(@app_root.join('config/application.rb')).to exist

    # Add opal-rails to the Gemfile
    gemfile = read_file('Gemfile')
    write_file('Gemfile', gemfile + "\ngem 'opal-rails', path: '#{GEM_ROOT}'\n")

    unbundled_run!('bundle install', label: 'bundle install', timeout: 180)

    # -----------------------------------------------------------------------
    # Phase 2: Install opal-rails and set up a basic app
    # -----------------------------------------------------------------------
    unbundled_run!('ruby bin/rails generate opal:install', label: 'opal:install')
    unbundled_run!('ruby bin/rails generate controller home index -f', label: 'generate controller')

    # Set the root route
    write_file('config/routes.rb', <<~RUBY)
      Rails.application.routes.draw do
        root to: "home#index"
      end
    RUBY

    # Write initial Opal code
    write_file('app/opal/application.rb', <<~RUBY)
      # backtick_javascript: true
      require 'opal'
      `window.opalMarker = "version_1"`
    RUBY

    # -----------------------------------------------------------------------
    # Phase 3: Start in development mode via bin/dev and verify
    #          (opal:watch performs the initial build implicitly)
    # -----------------------------------------------------------------------
    start_dev

    html = http_get('/').body
    expect(html).to include('<script')

    js = fetch_js_content('/')
    expect(js).to include('version_1')

    # -----------------------------------------------------------------------
    # Phase 4: Modify Opal code, let opal:watch rebuild, verify live
    # -----------------------------------------------------------------------
    write_file('app/opal/application.rb', <<~RUBY)
      # backtick_javascript: true
      require 'opal'
      `window.opalMarker = "version_2"`
    RUBY

    wait_for_js_content!('version_2')

    js = fetch_js_content('/')
    expect(js).to include('version_2')
    expect(js).not_to include('version_1')

    # -----------------------------------------------------------------------
    # Phase 5: Stop bin/dev, modify code, restart bin/dev, verify
    #          (opal:watch initial build picks up the offline changes)
    # -----------------------------------------------------------------------
    stop_dev

    write_file('app/opal/application.rb', <<~RUBY)
      # backtick_javascript: true
      require 'opal'
      `window.opalMarker = "version_3"`
    RUBY

    start_dev
    wait_for_js_content!('version_3')

    js = fetch_js_content('/')
    expect(js).to include('version_3')
    expect(js).not_to include('version_2')

    # -----------------------------------------------------------------------
    # Phase 6: Stop bin/dev, modify code, run tests
    #          (test:prepare triggers opal:build implicitly)
    # -----------------------------------------------------------------------
    stop_dev

    write_file('app/opal/application.rb', <<~RUBY)
      # backtick_javascript: true
      require 'opal'
      `window.opalMarker = "version_4"`
    RUBY

    # Create a simple integration test that checks the built JS content
    write_file('test/integration/opal_test.rb', <<~RUBY)
      require "test_helper"

      class OpalIntegrationTest < ActionDispatch::IntegrationTest
        test "opal assets contain the expected marker" do
          get "/"
          assert_response :success
          body = response.body

          # Extract JS asset src from the page
          js_src = body.scan(/src="([^"]*application[^"]*\\.js[^"]*)"/).flatten.first
          assert js_src, "Expected to find a JS script tag for application"

          get js_src
          assert_response :success
          assert_includes response.body, "version_4", "Expected the JS to contain version_4"
        end
      end
    RUBY

    # Remove the scaffold-generated controller test — its named route
    # (home_index_url) no longer exists because we replaced routes.rb.
    FileUtils.rm_f(@app_root.join('test/controllers/home_controller_test.rb').to_s)

    test_output = unbundled_run!(
      ['ruby', 'bin/rails', 'test'],
      env: { 'RAILS_ENV' => 'test' },
      label: 'rails test'
    )

    expect(test_output).to match(/1 (test|run)/)
    expect(test_output).to match(/0 failures/)

    # -----------------------------------------------------------------------
    # Phase 7: Modify code, assets:precompile, run production
    #          (assets:precompile triggers opal:build implicitly)
    # -----------------------------------------------------------------------
    write_file('app/opal/application.rb', <<~RUBY)
      # backtick_javascript: true
      require 'opal'
      `window.opalMarker = "version_5_production"`
    RUBY

    unbundled_run!(
      'ruby bin/rails assets:precompile',
      env: { 'RAILS_ENV' => 'production' },
      label: 'assets:precompile'
    )

    # Verify precompiled assets exist and contain our marker
    public_assets = Dir.glob(@app_root.join('public/assets/**/*.js').to_s)
    expect(public_assets).not_to be_empty, 'Expected precompiled JS assets in public/assets/'

    production_js = public_assets.map { |f| File.read(f) }.join("\n")
    expect(production_js).to include('version_5_production')

    start_server(env: 'production')

    html = http_get('/').body
    expect(html).to include('<script')

    js = fetch_js_content('/')
    expect(js).to include('version_5_production')

    stop_server
  end
end
