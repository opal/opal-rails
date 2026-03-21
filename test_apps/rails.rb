# FROM: http://www.rubytutorial.io/how-to-test-your-gem-against-multiple-rails/

require 'rails'
require 'rails/all'
require 'action_view/testing/resolvers'

require 'opal-rails' # our gem
require 'opal/rails/haml_filter'

RAILS_VERSION_SERIES = Gem::Version.new(Rails.gem_version.segments.first(2).join('.'))

module RailsApp
  class Application < Rails::Application
    config.root                                       = __dir__
    config.cache_classes                              = true
    config.eager_load                                 = false
    config.public_file_server.enabled                 = true
    config.public_file_server.headers                 = { 'Cache-Control' => 'public, max-age=3600' }
    config.consider_all_requests_local                = true
    config.action_controller.perform_caching          = false
    config.action_dispatch.show_exceptions            = false
    config.action_controller.allow_forgery_protection = false
    config.active_support.deprecation                 = :stderr
    config.secret_key_base                            = '49837489qkuweoiuoqwe'

    if RAILS_VERSION_SERIES < Gem::Version.new('8.0') && config.active_record.respond_to?(:legacy_connection_handling=)
      config.active_record.legacy_connection_handling = false
    end
    if RAILS_VERSION_SERIES == Gem::Version.new('8.0') && config.active_support.respond_to?(:to_time_preserves_timezone=)
      config.active_support.to_time_preserves_timezone = :zone
    end

    config.active_record.sqlite3.represent_boolean_as_integer = true if config.active_record.sqlite3

    config.middleware.delete Rack::Lock
    config.middleware.delete ActionDispatch::Flash

    routes.append do
      get '/' => 'application#index'
      get '/application/with_assignments' => 'application#with_assignments'
      get '/application/haml_filter' => 'application#haml_filter'

      # just to reduce noise
      get '/apple-touch-icon-precomposed.png' => proc { [404, {}, []] }
      get '/favicon.ico' => proc { [404, {}, []] }
    end

    config.assets.digest = true

    # Opal specific:
    config.opal.source_path = root.join('app/opal')
    config.opal.entrypoints_path = config.opal.source_path
    config.opal.build_path = root.join('app/assets/builds')
    config.opal.entrypoints = {
      'application' => 'application.rb',
      'source_map_example' => 'source_map_example.rb'
    }
    config.opal.source_map_enabled = true
  end
end

require_relative './app/application_controller'
RailsApp::Application.initialize!
