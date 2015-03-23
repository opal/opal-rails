module Opal
  module Rails
    class SpecBuilder
      def initialize(options)
        @root = options.fetch(:root) { ::Rails.root }
        @pattern = options.fetch(:pattern, nil)
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
        [spec_location] + Opal.paths + sprockets.paths
      end

      def main_code(files = spec_files)
        requires(files).map { |file| "require #{file.inspect}\n" }.join + boot_code
      end

      def requires(files)
        ['opal', 'opal-rspec', *files.map{|f| clean_spec_path(f)}]
      end

      def boot_code
        'Opal::RSpec::Runner.autorun'
      end

      def spec_files
        @spec_files ||= some_spec_files || all_spec_files
      end

      def some_spec_files
        return if pattern.blank?
        pattern.split(':').map { |path| spec_files_for_glob(path) }.flatten
      end

      def all_spec_files
        spec_files_for_glob '**/*_spec'
      end

      def spec_files_for_glob glob = '**'
        Dir[root.join("#{spec_location}/#{glob}{,.js}.{rb,opal}")]
      end

      def clean_spec_path(path)
        path.split("#{spec_location}/").flatten.last.gsub(/(\.js)?\.(rb|opal)$/, '')
      end
    end
  end
end
