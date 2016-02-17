# FROM: http://www.rubytutorial.io/how-to-test-your-gem-against-multiple-rails/

# test/apps/rails5.rb
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
    config.public_file_server.headers                 = { 'Cache-Control' => 'public, max-age=3600' }
    config.consider_all_requests_local                = true
    config.action_controller.perform_caching          = false
    config.action_dispatch.show_exceptions            = false
    config.action_controller.allow_forgery_protection = false
    config.active_support.deprecation                 = :stderr
    config.secret_key_base                            = '49837489qkuweoiuoqwe'

    config.middleware.delete Rack::Lock
    config.middleware.delete ActionDispatch::Flash

    routes.append do
      get '/' => 'application#index'
      get '/primary/with_assignments' => 'primary#with_assignments'
      get '/primary/without_assignments' => 'primary#without_assignments'
      get '/secondary/without_assignments' => 'secondary#without_assignments'
    end

    config.assets.paths << File.join(__dir__, 'assets/javascripts')
    config.assets.debug = true
    config.assets.digest = true

    # Opal specific:
    config.opal.source_map_enabled = true

  end
end

require_relative './templates'
require_relative './controllers'

RailsApp::Application.initialize!
