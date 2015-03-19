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
        builder.build_str main_code, 'opal_spec.rb'
        builder.to_s
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
        Opal.paths + sprockets.paths + [spec_location]
      end

      def main_code(files = spec_files)
        main_code = []
        main_code << 'require "opal"'
        main_code << 'require "opal-rspec"'
        files.each do |file|
          file = clean_spec_path(file)
          main_code << %Q{require #{file.inspect}}
        end
        main_code << 'Opal::RSpec::Runner.autorun'
        main_code.join("\n")
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
