require 'capybara/rspec'
require 'capybara/cuprite'

module BrowserSupport
  BROWSER_CANDIDATES = %w[
    chromium
    chromium-browser
    google-chrome
    google-chrome-stable
    chrome
    headless_shell
  ].freeze

  ABSOLUTE_BROWSER_CANDIDATES = %w[
    /usr/lib64/chromium-browser/headless_shell
    /usr/lib/chromium-browser/headless_shell
    /usr/lib/chromium/headless_shell
  ].freeze

  module_function

  def path
    env_path = ENV['BROWSER_PATH']
    return env_path if env_path && File.executable?(env_path)

    discovered_path = ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).find do |directory|
      BROWSER_CANDIDATES.any? do |name|
        File.executable?(File.join(directory, name))
      end
    end

    return File.join(discovered_path, discovered_executable_name(discovered_path)) if discovered_path

    ABSOLUTE_BROWSER_CANDIDATES.find { |candidate| File.executable?(candidate) }
  end

  def available?
    !path.nil?
  end

  def discovered_executable_name(directory)
    BROWSER_CANDIDATES.find do |name|
      File.executable?(File.join(directory, name))
    end
  end
end

module OpalHelper
  def compile_opal(code)
    Opal.compile(code, requireable: false)
  end

  def execute_opal(code)
    execute_script compile_opal(code)
  end

  def evaluate_opal(code)
    # Remove the initial comment that prevents evaluate from worning
    evaluate_script compile_opal(code).strip.lines[1..-1].join("\n")
  end

  def expect_opal(code)
    expect(evaluate_opal(code))
  end

  def expect_script(code)
    expect(evaluate_script(code))
  end

  def opal_nil
    @opal_nil ||= evaluate_opal 'nil'
  end

  def wait_for_dom_ready(expire_in: Capybara.default_max_wait_time)
    timer = Capybara::Helpers.timer(expire_in: expire_in)

    until evaluate_script('document.readyState') == 'complete'
      raise "reached max time (#{expire_in}s)" if timer.expired?

      sleep 0.01
    end
  end

  def wait_for_opal_ready(expire_in: Capybara.default_max_wait_time)
    timer = Capybara::Helpers.timer(expire_in: expire_in)

    until evaluate_script('!!(window.Opal && window.Opal.gvars.ready)')
      raise "reached max time (#{expire_in}s)" if timer.expired?

      sleep 0.01
    end
  end

  def reset_dom
    visit '/'
  end
end

RSpec.configure do |config|
  config.include OpalHelper

  browser_path = BrowserSupport.path

  config.before(:each, js: true) do
    skip 'Browser-dependent spec skipped because no browser binary is available' unless BrowserSupport.available?
  end

  config.before(:suite) do
    ENV['BROWSER_PATH'] ||= browser_path if browser_path
  end

  config.append_after(:each, js: true) do
    session = Capybara.current_session
    session.driver.restart if session.driver.is_a?(Capybara::Cuprite::Driver)
  end
end
