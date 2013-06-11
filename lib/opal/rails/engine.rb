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

      initializer 'opal.asset_paths', :after => 'sprockets.environment', :group => :all do |app|
        app.config.before_initialize do
          app.config.eager_load_paths = app.config.eager_load_paths.dup - Dir["#{app.root}/app/{assets,views}"]
        end

        Opal.paths.each do |path|
          app.assets.append_path path
        end

        Opal.default_options = config.opal
      end

      config.after_initialize do |app|
        config = app.config
        maps_app = Opal::SourceMapServer.new(app.assets)

        if config.opal.source_map_enabled
          app.routes.prepend do
            mount maps_app => maps_app.prefix
            get '/opal_spec' => 'opal_spec#run'
          end
        end
      end

    end
  end
end
