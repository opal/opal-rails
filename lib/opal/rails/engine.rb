require 'rails'
require 'opal/sprockets/server'
require 'opal/sprockets/processor'
require 'opal/rails/spec_builder'

module Opal
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :opal

      config.opal = ActiveSupport::OrderedOptions.new
      # new default location, override-able in a Rails initializer
      config.opal.spec_location = "spec-opal"
      config.opal.dynamic_require_severity = :ignore

      # Cache eager_load_paths now, otherwise the assets dir is added
      # and its .rb files are eagerly loaded.
      config.eager_load_paths

      config.before_initialize do |app|
        app.config.eager_load_paths = app.config.eager_load_paths.dup - Dir["#{app.root}/app/{assets,views}"]
      end

      initializer 'opal.asset_paths', :after => 'sprockets.environment', :group => :all do |app|
        spec_location = app.root.join(app.config.opal.spec_location).to_s
        runner_dir = ::Opal::Rails::SpecBuilder.runner_dir(app.root)
        runner_dir.mkpath

        app.assets.append_path runner_dir.to_s
        app.assets.append_path spec_location
        Opal.paths.each do |path|
          app.assets.append_path path
        end

        app.config.assets.precompile << "#{runner_dir}/*.js"
      end

      config.after_initialize do |app|
        require 'opal/rails/haml_filter' if defined?(Haml)
        require 'opal/rails/slim_filter' if defined?(Slim)

        config = app.config
        config.opal.each_pair do |key, value|
          key = "#{key}="
          Opal::Processor.send(key, value) if Opal::Processor.respond_to? key
        end

        app.routes.prepend do
          if Opal::Processor.source_map_enabled && config.assets.compile
            maps_prefix = '/__OPAL_SOURCE_MAPS__'
            maps_app    = Opal::SourceMapServer.new(app.assets, maps_prefix)

            ::Opal::Sprockets::SourceMapHeaderPatch.inject!(maps_prefix)

            mount maps_app => maps_prefix
          end

          get '/opal_spec' => 'opal_spec#run', as: :opal_spec
        end
      end

    end
  end
end
