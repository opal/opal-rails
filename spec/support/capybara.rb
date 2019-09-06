require 'capybara/rspec'
require 'capybara/apparition'

Capybara.javascript_driver = :apparition

Capybara.register_server :puma do |app, port, host|
  require 'rack/handler/puma'
  Rack::Handler::Puma.run(app, Host: host, Port: port, Threads: "0:4", Silent: true)
end

Capybara.default_max_wait_time = 5

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
end
