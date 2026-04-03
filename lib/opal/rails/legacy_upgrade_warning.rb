module Opal
  module Rails
    module LegacyUpgradeWarning
      module_function

      LEGACY_OPAL_CONFIG_KEYS = %w[
        method_missing_enabled
        const_missing_enabled
        arity_check_enabled
        freezing_stubs_enabled
        missing_require_severity
      ].freeze

      BUILD_CONFIG_KEYS = %w[
        source_path
        entrypoints_path
        build_path
        entrypoints
      ].freeze

      def warn_if_needed(app, output: $stderr)
        return false if suppress_warning?(app)

        warning = warning_for(app.root)
        return false unless warning

        output.puts(warning)
        true
      end

      def warning_for(root)
        signals = legacy_signals(root)
        return if signals.empty?

        <<~WARNING
          WARNING: opal-rails detected a likely 2.x application layout that has not been ported to the 3.x build pipeline yet.

          This app may fail after upgrade with missing `app/opal` entrypoints or missing `application.js` assets.
          Pin `opal-rails` to the 2.0 series until the app can be ported, or follow `PORTING.md` before continuing.
          If you have already ported the app and want to silence this check, set `config.opal.suppress_legacy_upgrade_warning = true`.

          Detected legacy signals:
          #{signals.map { |signal| "- #{signal}" }.join("\n")}
        WARNING
      end

      def suppress_warning?(app)
        return false unless app.respond_to?(:config)

        app.config.respond_to?(:opal) && app.config.opal.suppress_legacy_upgrade_warning
      end

      def legacy_signals(root)
        root = Pathname(root)
        signals = []

        initializer = root.join('config/initializers/opal.rb')
        initializer_body = initializer.exist? ? initializer.read : nil

        if legacy_initializer?(initializer_body)
          signals << 'config/initializers/opal.rb still uses legacy 2.x runtime settings'
        end

        legacy_entrypoints(root).each do |entrypoint|
          signals << "legacy Opal asset entrypoint present at #{relative_to_root(entrypoint, root)}"
        end

        manifest = root.join('app/assets/config/manifest.js')
        if manifest.exist? && manifest.read.match?(%r{link_(?:tree|directory)\s+\.\./javascript\b})
          signals << 'app/assets/config/manifest.js still links the legacy javascript asset tree'
        end

        return [] unless initializer_body && signals.length >= 2
        return signals if root.join('app/opal').directory?

        signals << 'expected 3.x source root app/opal is missing'
      end

      def legacy_initializer?(initializer_body)
        return false unless initializer_body
        return false if BUILD_CONFIG_KEYS.any? { |key| initializer_body.include?("config.opal.#{key}") }

        LEGACY_OPAL_CONFIG_KEYS.any? { |key| initializer_body.include?("config.opal.#{key}") }
      end

      def legacy_entrypoints(root)
        Dir[root.join('app/assets/{javascript,javascripts}/**/*.js.rb').to_s].sort.map { |path| Pathname(path) }
      end

      def relative_to_root(path, root)
        path.relative_path_from(root).to_s
      end
    end
  end
end
