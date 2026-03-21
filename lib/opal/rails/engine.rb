require 'rails'

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
        Opal::Rails::PathSetup.apply!(app)
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
