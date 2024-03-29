# FROM: http://www.rubytutorial.io/how-to-test-your-gem-against-multiple-rails/

require 'rails'
require 'rails/all'
require 'action_view/testing/resolvers'

require 'opal-rails' # our gem
require 'opal/rails/haml_filter'

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

    if config.active_record.sqlite3
      config.active_record.sqlite3.represent_boolean_as_integer = true
    end

    config.middleware.delete Rack::Lock
    config.middleware.delete ActionDispatch::Flash

    routes.append do
      get '/' => 'application#index'
      get '/application/with_assignments' => 'application#with_assignments'
      get '/application/haml_filter' => 'application#haml_filter'

      # just to reduce noise
      get '/apple-touch-icon-precomposed.png' => proc { [404,{},[]] }
      get '/favicon.ico' => proc { [404,{},[]] }
    end

    config.assets.debug = true
    config.assets.digest = true

    # Opal specific:
    config.opal.source_map_enabled = true
  end
end

require_relative './app/application_controller'
RailsApp::Application.initialize!
