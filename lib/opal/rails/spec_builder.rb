require 'digest'

module Opal
  module Rails
    class SpecBuilder
      def initialize(options)
        @root = options.fetch(:root) { ::Rails.root }
        @pattern = options[:pattern] || '**/*_spec'
        @sprockets = options.fetch(:sprockets)
        @spec_location = options.fetch(:spec_location)
      end

      attr_reader :sprockets, :pattern, :spec_location, :root

      def to_s
        builder.build_str main_code, 'opal_spec'
        builder.to_s + 'Opal.load("opal_spec");'
      end

      def builder
        @builder ||= begin
          path_finder = Opal::HikePathFinder.new(paths)

          Opal::Builder.new(
            compiler_options: Opal::Processor.compiler_options,
            stubs:            Opal::Processor.stubbed_files,
            path_reader:      Opal::PathReader.new(path_finder),
          )
        end
      end

      def paths
        [
          root.join(spec_location).to_s,
          runner_dir.to_s,
          *Opal.paths,
          *sprockets.paths,
        ]
      end

      def self.runner_dir(root)
        root.join('tmp/opal_spec')
      end

      def runner_dir
        self.class.runner_dir(root)
      end

      def main_code
        requires.map { |file| "require #{file.inspect}\n" }.join + boot_code
      end

      def runner_pathname
        runner_dir.join("#{runner_logical_path}.js.rb")
      end

      def runner_logical_path
        "opal_spec_runner_#{digest}"
      end

      def digest
        # The digest is cached as it shouldn't change
        # for a given builder instance
        @digest ||= Digest::SHA1.new.update(requires.join).to_s
      end

      def requires
        ['opal', 'opal-rspec', *clean_spec_files]
      end

      def clean_spec_files
        spec_files.map{|f| clean_spec_path(f)}
      end

      def boot_code
        'Opal::RSpec::Runner.autorun'
      end

      def spec_files
        @spec_files ||= pattern.split(':').map { |path| spec_files_for_glob(path) }.flatten
      end

      def spec_files_for_glob(glob)
        Dir[root.join("#{spec_location}/#{glob}{,.js}.{rb,opal}").to_s]
      end

      def clean_spec_path(path)
        path.split("#{spec_location}/").flatten.last.gsub(/(\.js)?\.(rb|opal)$/, '')
      end
    end
  end
end
