# FROM: http://www.rubytutorial.io/how-to-test-your-gem-against-multiple-rails/

# test/apps/rails4.rb
require 'rails'
require 'rails/all'
require 'action_view/testing/resolvers'

require 'opal-rails' # our gem

module RailsApp
  class Application < Rails::Application
    config.root                                       = __dir__
    config.cache_classes                              = true
    config.eager_load                                 = false
    config.serve_static_files                         = true
    config.static_cache_control                       = 'public, max-age=3600'
    config.consider_all_requests_local                = true
    config.action_controller.perform_caching          = false
    config.action_dispatch.show_exceptions            = false
    config.action_controller.allow_forgery_protection = false
    config.active_support.deprecation                 = :stderr
    config.secret_key_base                            = '49837489qkuweoiuoqwe'

    config.middleware.delete 'Rack::Lock'
    config.middleware.delete 'ActionDispatch::Flash'
    config.middleware.delete 'ActionDispatch::BestStandardsSupport'

    routes.append do
      get '/' => 'application#index'
      get '/application/with_assignments' => 'application#with_assignments'
    end

    config.assets.paths << File.join(__dir__, 'assets/javascripts')
    config.assets.debug = true
    config.assets.digest = true

    # Opal specific:
    config.opal.source_map_enabled = true
  end
end

LAYOUT = <<-HTML
<!DOCTYPE html>
<html>
<head><%= javascript_include_tag "application" %></head>
<body><%= yield %></body>
</html>
HTML

INDEX = <<-HTML
<script type="text/ruby">
raise 'pippo'
</script>
HTML

WITH_ASSIGNMENTS = <<-RUBY
return {
  number_var: @number_var,
  string_var: @string_var,
  array_var:  @array_var,
  hash_var:   @hash_var,
  object_var: @object_var,
  local_var:  local_var
}.to_n
RUBY

class ApplicationController < ActionController::Base

  include Rails.application.routes.url_helpers
  layout 'application'
  self.view_paths = [ActionView::FixtureResolver.new(
    'layouts/application.html.erb'         => LAYOUT,
    'application/index.html.erb'           => INDEX,
    'application/with_assignments.js.opal' => WITH_ASSIGNMENTS,
  )]

  def index
  end

  def with_assignments
    object = Object.new
    def object.as_json options = {}
      {contents: 'json representation'}
    end

    @number_var = 1234
    @string_var = 'hello'
    @array_var  = [1,'a']
    @hash_var   = {a: 1, b: 2}
    @object_var = object

    render type: :js, locals: { local_var: 'i am local' }
  end
end

RailsApp::Application.initialize!
