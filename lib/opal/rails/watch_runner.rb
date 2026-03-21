# frozen_string_literal: true

require 'pathname'

module Opal
  module Rails
    class WatchRunner
      def initialize(config:, resolver: nil, builder_runner: nil, manifest: nil, file_watcher_class: FileWatcher,
                     output: $stdout, error_output: $stderr, kernel: Kernel)
        @config = config
        @resolver = resolver
        @builder_runner = builder_runner
        @manifest = manifest
        @file_watcher_class = file_watcher_class
        @output = output
        @error_output = error_output
        @kernel = kernel
        @dependencies_by_entrypoint = {}
        @outputs_by_entrypoint = {}
        @reverse_dependencies = Hash.new { |hash, key| hash[key] = [] }
        @opal_dependencies = []
      end

      def watch
        start!
        output.puts '* Opal watcher started'
        kernel.sleep
      rescue Interrupt
        output.puts '* Stopping Opal watcher...'
      ensure
        watcher&.stop
      end

      def start!
        rebuild_all!
      end

      def process_changes(modified:, added:, removed:)
        modified = normalize_paths(modified)
        added = normalize_paths(added)
        removed = normalize_paths(removed)
        changed = (modified + added + removed).uniq.sort
        return if changed.empty?

        if full_rebuild_required?(changed: changed, modified: modified, added: added, removed: removed)
          error_output.puts "* Modified code: #{changed.join(', ')}; rebuilding all entrypoints"
          rebuild_all!
        else
          logical_names = modified.flat_map { |path| reverse_dependencies[path] }.uniq.sort
          return if logical_names.empty?

          error_output.puts "* Modified code: #{modified.join(', ')}; rebuilding #{logical_names.join(', ')}"
          rebuild_entrypoints!(logical_names)
        end
      end

      private

      attr_reader :builder_runner, :config, :error_output, :file_watcher_class, :kernel, :manifest, :opal_dependencies,
                  :output, :resolved_entrypoints, :resolver, :reverse_dependencies
      attr_accessor :watcher

      def rebuild_all!
        @resolved_entrypoints = current_resolver.resolve
        result = current_builder_runner.build(entrypoints: resolved_entrypoints)

        @dependencies_by_entrypoint = normalize_dependency_map(result.fetch(:dependencies))
        @outputs_by_entrypoint = resolved_entrypoints.each_with_object({}) do |(logical_name, _), outputs|
          outputs[logical_name] = outputs_for(logical_name)
        end

        current_manifest.prune_stale!(owned_outputs)
        current_manifest.write!(owned_outputs)
        refresh_watcher!
      rescue StandardError => e
        error_output.puts "* Opal build error: #{e.message}"
        refresh_watcher! if @resolved_entrypoints
      end

      def rebuild_entrypoints!(logical_names)
        entrypoints = resolved_entrypoints.slice(*logical_names)
        result = current_builder_runner.build(entrypoints: entrypoints)

        normalize_dependency_map(result.fetch(:dependencies)).each_pair do |logical_name, files|
          @dependencies_by_entrypoint[logical_name] = files
        end

        current_manifest.write!(owned_outputs)
        refresh_watcher!
      rescue StandardError => e
        error_output.puts "* Opal build error: #{e.message}"
      end

      def refresh_watcher!
        @opal_dependencies = normalize_paths(Opal.dependent_files)
        rebuild_reverse_dependencies!

        watcher&.stop
        self.watcher = file_watcher_class.new(files: watched_files,
                                              extra_directories: extra_directories) do |modified:, added:, removed:|
          process_changes(modified: modified, added: added, removed: removed)
        end
        watcher.start
      end

      def rebuild_reverse_dependencies!
        @reverse_dependencies = Hash.new { |hash, key| hash[key] = [] }

        @dependencies_by_entrypoint.each_pair do |logical_name, files|
          files.each { |path| @reverse_dependencies[path] << logical_name }
        end
      end

      def watched_files
        (opal_dependencies + @dependencies_by_entrypoint.values.flatten).uniq.sort
      end

      def owned_outputs
        @outputs_by_entrypoint.values.flatten.uniq.sort
      end

      def outputs_for(logical_name)
        outputs = ["#{logical_name}.js"]
        outputs << "#{logical_name}.js.map" if source_map_enabled?
        outputs
      end

      def full_rebuild_required?(changed:, modified:, added:, removed:)
        return true unless (changed & opal_dependencies).empty?
        return true unless added.empty? && removed.empty?
        return true if modified.any? { |path| reverse_dependencies[path].empty? }

        false
      end

      def source_map_enabled?
        value = config[:source_map_enabled]
        value.nil? ? Opal::Config.source_map_enabled : value
      end

      def extra_directories
        directories = [config.source_path]
        directories << config.entrypoints_path if config.entrypoints == :all
        normalize_paths(directories)
      end

      def current_resolver
        @resolver ||= EntrypointsResolver.new(
          entrypoints_path: config.entrypoints_path,
          entrypoints: config.entrypoints
        )
      end

      def current_builder_runner
        @builder_runner ||= BuilderRunner.new(config: config)
      end

      def current_manifest
        @manifest ||= OutputsManifest.new(build_path: config.build_path)
      end

      def normalize_dependency_map(dependencies)
        dependencies.each_with_object({}) do |(logical_name, files), normalized|
          normalized[logical_name] = normalize_paths(files)
        end
      end

      def normalize_paths(paths)
        Array(paths).map { |path| Pathname(path).expand_path.to_s }.uniq.sort
      end
    end
  end
end
