# frozen_string_literal: true

require 'pathname'

module Opal
  module Rails
    module PathSetup
      module_function

      def apply!(app, autoloaders: ::Rails.autoloaders)
        app.config.opal.source_path ||= app.root.join('app/opal')
        app.config.opal.entrypoints_path ||= app.config.opal.source_path
        app.config.opal.build_path ||= app.root.join('app/assets/builds')

        source_path = Pathname(app.config.opal.source_path).expand_path
        app_assets_path = app.root.join('app/assets').expand_path

        app.config.eager_load_paths = app.config.eager_load_paths.dup - Dir["#{app.root}/app/{assets,views}"]

        app.config.eager_load_paths -= [source_path.to_s] if source_path.to_s.start_with?(app.root.join('app').to_s)

        return if source_path.to_s.start_with?(app_assets_path.to_s)

        Array(autoloaders).each { |autoloader| autoloader.ignore(source_path) }
      end
    end
  end
end
