# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'pathname'
require 'tempfile'

module Opal
  module Rails
    class OutputsManifest
      FILE_NAME = '.opal-build-manifest.json'

      def initialize(build_path:)
        @build_path = Pathname(build_path).expand_path
      end

      def read_outputs
        return [] unless manifest_path.exist?

        JSON.parse(manifest_path.read).fetch('outputs')
      rescue JSON::ParserError, KeyError
        nil
      end

      def prune_stale!(current_outputs)
        previous_outputs = read_outputs
        return false if previous_outputs.nil?

        stale_outputs(previous_outputs, current_outputs).each do |relative_path|
          full_path = safe_build_path(relative_path)
          full_path.delete if full_path&.exist?
        end

        true
      end

      def write!(outputs)
        FileUtils.mkdir_p(build_path)

        Tempfile.create(['opal-build-manifest', '.json'], build_path.to_s) do |file|
          file.write(JSON.pretty_generate('version' => 1, 'outputs' => outputs.sort))
          file.flush
          FileUtils.mv(file.path, manifest_path)
        end
      end

      def clobber!
        outputs = read_outputs
        return nil if outputs.nil?

        outputs.each do |relative_path|
          full_path = safe_build_path(relative_path)
          full_path.delete if full_path&.exist?
        end

        manifest_path.delete if manifest_path.exist?

        outputs
      end

      private

      attr_reader :build_path

      def manifest_path
        build_path.join(FILE_NAME)
      end

      def stale_outputs(previous_outputs, current_outputs)
        previous_outputs - current_outputs
      end

      def safe_build_path(relative_path)
        full_path = build_path.join(relative_path).expand_path
        return full_path if full_path.to_s.start_with?(build_path.to_s + File::SEPARATOR) ||
                            full_path.to_s == build_path.to_s

        nil
      end
    end
  end
end
