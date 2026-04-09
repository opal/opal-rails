# frozen_string_literal: true

require 'pathname'

module Opal
  module Rails
    class EntrypointsResolver
      def initialize(entrypoints_path:, entrypoints:)
        @entrypoints_path = Pathname(entrypoints_path).expand_path
        @entrypoints = entrypoints
      end

      def resolve
        case entrypoints
        when Hash
          resolve_hash
        when :all
          resolve_all
        else
          raise InvalidEntrypointsConfigError,
                "config.opal.entrypoints must be a Hash or :all, got #{entrypoints.inspect}"
        end
      end

      private

      attr_reader :entrypoints_path, :entrypoints

      def resolve_hash
        resolved = {}

        unless entrypoints_path.directory?
          raise MissingEntrypointError,
                "Opal entrypoints_path #{entrypoints_path} does not exist"
        end

        entrypoints.each_pair do |logical_name, relative_source_file|
          logical_name = logical_name.to_s
          relative_source_file = relative_source_file.to_s
          absolute_source_file = entrypoints_path.join(relative_source_file)

          unless absolute_source_file.file?
            raise MissingEntrypointError,
                  "configured Opal entrypoint #{relative_source_file.inspect} was not found under #{entrypoints_path}"
          end

          if resolved.key?(logical_name)
            raise DuplicateEntrypointError,
                  "duplicate Opal logical entrypoint #{logical_name.inspect}"
          end

          resolved[logical_name] = relative_source_file
        end

        resolved
      end

      def resolve_all
        unless entrypoints_path.directory?
          raise MissingEntrypointError,
                "Opal entrypoints_path #{entrypoints_path} does not exist"
        end

        entrypoints_path.children
                        .select(&:file?)
                        .select { |path| path.extname == '.rb' }
                        .sort_by { |path| path.basename.to_s }
                        .each_with_object({}) do |path, resolved|
          logical_name = path.basename('.rb').to_s

          if resolved.key?(logical_name)
            raise DuplicateEntrypointError,
                  "duplicate Opal logical entrypoint #{logical_name.inspect}"
          end

          resolved[logical_name] = path.basename.to_s
        end
      end
    end
  end
end
