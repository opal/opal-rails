require 'rails'
require 'opal/default_options'
require 'opal/server'

module Opal
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :opal

      config.opal = ActiveSupport::OrderedOptions.new


      # Cache eager_load_paths now, otherwise the assets dir is added
      # and its .rb files are eagerly loaded.
      config.eager_load_paths

      config.before_initialize do |app|
        app.config.eager_load_paths = app.config.eager_load_paths.dup - Dir["#{app.root}/app/{assets,views}"]
      end

      config.after_initialize do |app|
        Opal.paths.each do |path|
          app.assets.append_path path
        end

        Opal.default_options = config.opal

        config = app.config
        maps_app = Opal::SourceMapServer.new(app.assets)

        app.routes.prepend do
          mount maps_app => maps_app.prefix
          get '/opal_spec' => 'opal_spec#run'
        end
      end

    end
  end
end
