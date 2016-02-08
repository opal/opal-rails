require 'rails'
require 'opal/sprockets/server'
require 'opal/sprockets/processor'
require 'opal/rails/configuration'

module Opal
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :opal

      config.opal = Opal::Rails::Configuration.new

      config.opal.dynamic_require_severity = :ignore

      # Cache eager_load_paths now, otherwise the assets dir is added
      # and its .rb files are eagerly loaded.
      config.eager_load_paths

      config.before_initialize do |app|
        app.config.eager_load_paths = app.config.eager_load_paths.dup - Dir["#{app.root}/app/{assets,views}"]
      end

      initializer 'opal.asset_paths', :after => 'sprockets.environment', :group => :all do |app|
        Opal.paths.each do |path|
          app.assets.append_path path
        end
      end

      config.after_initialize do |app|
        require 'opal/rails/haml_filter' if defined?(Haml)
        require 'opal/rails/slim_filter' if defined?(Slim)

        config = app.config
        config.opal.configure_processor

        app.routes.prepend do
          if Opal::Processor.source_map_enabled && config.assets.compile && config.assets.debug
            maps_prefix = '/__OPAL_SOURCE_MAPS__'
            maps_app    = Opal::SourceMapServer.new(app.assets, maps_prefix)

            ::Opal::Sprockets::SourceMapHeaderPatch.inject!(maps_prefix)

            mount maps_app => maps_prefix
          end
        end

      end
    end
  end
end
