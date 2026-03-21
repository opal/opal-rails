# frozen_string_literal: true

require 'fileutils'
require 'pathname'

module Opal
  module Rails
    class BuilderRunner
      def initialize(config:)
        @config = config
      end

      def build(entrypoints:)
        with_opal_config do
          outputs = []
          dependencies = {}

          FileUtils.mkdir_p(build_path)

          entrypoints.each_pair do |logical_name, relative_source_file|
            builder = build_entrypoint(relative_source_file)
            js_output = "#{logical_name}.js"

            write_output(js_output, compiled_source_for(builder, js_output))
            outputs << js_output

            if source_map_enabled?
              map_output = "#{js_output}.map"
              write_output(map_output, builder.source_map.to_json)
              outputs << map_output
            end

            dependencies[logical_name] = builder.dependent_files
          end

          {
            outputs: outputs,
            dependencies: dependencies
          }
        end
      end

      private

      attr_reader :config

      def build_entrypoint(relative_source_file)
        builder = Opal::Builder.new(
          compiler_options: Opal::Config.compiler_options,
          missing_require_severity: Opal::Config.missing_require_severity
        )

        builder.append_paths(*builder_paths)
        Array(config.use_gems).each { |gem_name| builder.use_gem(gem_name) }
        builder.build(relative_source_file)
        builder
      end

      def builder_paths
        [
          config.source_path,
          config.entrypoints_path,
          *Array(config.append_paths)
        ].compact.map { |path| Pathname(path).expand_path.to_s }.uniq
      end

      def build_path
        Pathname(config.build_path).expand_path
      end

      def source_map_enabled?
        value = config[:source_map_enabled]
        value.nil? ? Opal::Config.source_map_enabled : value
      end

      def compiled_source_for(builder, js_output)
        source = builder.to_s
        return source unless source_map_enabled?

        [source, "//# sourceMappingURL=#{File.basename(js_output)}.map", nil].join("\n")
      end

      def write_output(relative_path, contents)
        output_path = build_path.join(relative_path)
        FileUtils.mkdir_p(output_path.dirname)
        output_path.write(contents)
      end

      def with_opal_config
        original_config = snapshot_opal_config
        apply_app_config_to_opal!
        yield
      ensure
        restore_opal_config(original_config)
      end

      def snapshot_opal_config
        Opal::Config.config.each_with_object({}) do |(key, value), snapshot|
          snapshot[key] = begin
            value.dup
          rescue TypeError
            value
          end
        end
      end

      def apply_app_config_to_opal!
        config.each_pair do |key, value|
          setter = "#{key}="
          Opal::Config.public_send(setter, value) if Opal::Config.respond_to?(setter)
        end
      end

      def restore_opal_config(snapshot)
        return unless snapshot

        Opal::Config.reset!
        snapshot.each_pair do |key, value|
          setter = "#{key}="
          Opal::Config.public_send(setter, value) if Opal::Config.respond_to?(setter)
        end
      end
    end
  end
end
