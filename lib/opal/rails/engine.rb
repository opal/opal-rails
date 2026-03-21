require 'rails'
require 'opal/sprockets'
require 'sprockets/railtie'

module Opal
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :opal

      config.opal = ActiveSupport::OrderedOptions.new

      config.opal.dynamic_require_severity = :ignore
      config.opal.assigns_in_templates = true
      config.opal.entrypoints = { 'application' => 'application.rb' }
      config.opal.append_paths = []
      config.opal.use_gems = []

      def (config.opal).assign_locals_in_templates?
        [true, :locals].include?(assigns_in_templates)
      end

      def (config.opal).assign_instance_variables_in_templates?
        [true, :ivars].include?(assigns_in_templates)
      end

      # Cache eager_load_paths now, otherwise the assets dir is added
      # and its .rb files are eagerly loaded.
      config.eager_load_paths

      config.before_initialize do |app|
        app.config.opal.source_path ||= app.root.join('app/opal')
        app.config.opal.entrypoints_path ||= app.config.opal.source_path
        app.config.opal.build_path ||= app.root.join('app/assets/builds')

        source_path = Pathname(app.config.opal.source_path).expand_path
        app_assets_path = app.root.join('app/assets').expand_path

        app.config.eager_load_paths = app.config.eager_load_paths.dup - Dir["#{app.root}/app/{assets,views}"]

        app.config.eager_load_paths -= [source_path.to_s] if source_path.to_s.start_with?(app.root.join('app').to_s)

        unless source_path.to_s.start_with?(app_assets_path.to_s)
          ::Rails.autoloaders.each { |autoloader| autoloader.ignore(source_path) }
        end

        assets_config = app.config.assets if app.config.respond_to?(:assets)
        if app.config.opal.exclude_source_path_from_assets &&
           assets_config &&
           assets_config.respond_to?(:excluded_paths) &&
           source_path.to_s.start_with?(app_assets_path.to_s)
          excluded_paths = Array(assets_config.excluded_paths)
          unless excluded_paths.any? { |existing| Pathname(existing).expand_path == source_path }
            assets_config.excluded_paths << source_path
          end
        end
      end

      initializer 'opal.append_assets_path', after: :append_assets_path, group: :all do |app|
        app.config.assets.paths.unshift(*Opal.paths)
      end

      config.after_initialize do |app|
        require 'opal/rails/haml_filter' if defined?(Haml)
        require 'opal/rails/slim_filter' if defined?(Slim)

        config = app.config
        config.opal.each_pair do |key, value|
          key = "#{key}="
          Opal::Config.send(key, value) if Opal::Config.respond_to? key
        end
      end

      rake_tasks do
        load File.expand_path('../../tasks/opal.rake', __dir__)
      end
    end
  end
end
