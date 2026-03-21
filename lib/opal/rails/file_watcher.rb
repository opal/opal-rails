# frozen_string_literal: true

require 'pathname'

module Opal
  module Rails
    class FileWatcher
      def initialize(files:, extra_directories: [], &callback)
        @files = normalize_paths(files)
        @extra_directories = normalize_paths(extra_directories)
        @callback = callback
      end

      def start
        require 'listen'

        @listener = Listen.to(*directories) do |modified, added, removed|
          callback.call(
            modified: normalize_paths(modified),
            added: normalize_paths(added),
            removed: normalize_paths(removed)
          )
        end
        @listener.start
      rescue LoadError
        raise Error, 'opal:watch requires the listen gem'
      end

      def stop
        @listener&.stop
      end

      private

      attr_reader :callback, :extra_directories, :files

      def directories
        dirs = files.map { |file| File.directory?(file) ? file : File.dirname(file) }
        collapse_directories((dirs + extra_directories).uniq.sort)
      end

      def collapse_directories(directories)
        previous_dir = nil

        directories.each_with_object([]) do |dir, collapsed|
          next if previous_dir && dir.start_with?(previous_dir + File::SEPARATOR)

          collapsed << dir
          previous_dir = dir
        end
      end

      def normalize_paths(paths)
        Array(paths).map { |path| Pathname(path).expand_path.to_s }.uniq.sort
      end
    end
  end
end
