require 'rails'
require 'opal/sprockets/server'
require 'opal/sprockets/processor'

module Opal
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :opal

      config.opal = ActiveSupport::OrderedOptions.new

      config.opal.dynamic_require_severity = :ignore
      config.opal.assigns_in_templates = true

      def (config.opal).assign_locals_in_templates?
        assigns_in_templates == true || assigns_in_templates == :locals
      end

      def (config.opal).assign_instance_variables_in_templates?
        assigns_in_templates == true || assigns_in_templates == :ivars
      end

      # Cache eager_load_paths now, otherwise the assets dir is added
      # and its .rb files are eagerly loaded.
      config.eager_load_paths

      config.before_initialize do |app|
        app.config.eager_load_paths = app.config.eager_load_paths.dup - Dir["#{app.root}/app/{assets,views}"]
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

    end
  end
end
