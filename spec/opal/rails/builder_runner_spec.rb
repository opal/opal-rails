require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe Opal::Rails::BuilderRunner do
  around do |example|
    Dir.mktmpdir do |dir|
      @root = Pathname(dir)
      @source_path = @root.join('app/opal')
      @entrypoints_path = @root.join('app/opal/entrypoints')
      @build_path = @root.join('app/assets/builds')
      @shared_path = @root.join('app/shared/opal')

      FileUtils.mkdir_p(@source_path)
      FileUtils.mkdir_p(@entrypoints_path)
      FileUtils.mkdir_p(@build_path)
      FileUtils.mkdir_p(@shared_path)

      example.run
    end
  end

  it 'builds configured entrypoints and writes source maps' do
    @source_path.join('message.rb').write("module Message\n  def self.text\n    'hello from opal'\n  end\nend\n")
    @entrypoints_path.join('application.rb').write("require 'opal'\nrequire 'message'\nputs Message.text\n")

    config = ActiveSupport::OrderedOptions.new
    config.source_path = @source_path
    config.entrypoints_path = @entrypoints_path
    config.build_path = @build_path
    config.append_paths = []
    config.use_gems = []
    config.source_map_enabled = true

    result = described_class.new(config: config).build(
      entrypoints: { 'application' => 'application.rb' }
    )

    expect(result[:outputs]).to contain_exactly('application.js', 'application.js.map')
    expect(@build_path.join('application.js').read).to include('sourceMappingURL=application.js.map')
    expect(@build_path.join('application.js').read).to include('hello from opal')
    expect(@build_path.join('application.js.map').read).to include('"version"')
    expect(result[:dependencies]['application']).to include(@entrypoints_path.join('application.rb').to_s)
    expect(result[:dependencies]['application']).to include(@source_path.join('message.rb').to_s)
  end

  it 'builds the file from entrypoints_path when source roots share a basename' do
    @source_path.join('application.rb').write("puts 'support file'\n")
    @entrypoints_path.join('application.rb').write("require 'opal'\nputs 'entrypoint file'\n")

    config = ActiveSupport::OrderedOptions.new
    config.source_path = @source_path
    config.entrypoints_path = @entrypoints_path
    config.build_path = @build_path
    config.append_paths = []
    config.use_gems = []
    config.source_map_enabled = false

    described_class.new(config: config).build(
      entrypoints: { 'application' => 'application.rb' }
    )

    built_source = @build_path.join('application.js').read
    expect(built_source).to include('entrypoint file')
    expect(built_source).not_to include('support file')
  end

  it 'resolves requires from configured append_paths' do
    @shared_path.join('shared_message.rb').write("module SharedMessage\n  def self.text\n    'hello from append paths'\n  end\nend\n")
    @entrypoints_path.join('application.rb').write("require 'opal'\nrequire 'shared_message'\nputs SharedMessage.text\n")

    config = ActiveSupport::OrderedOptions.new
    config.source_path = @source_path
    config.entrypoints_path = @entrypoints_path
    config.build_path = @build_path
    config.append_paths = [@shared_path]
    config.use_gems = []
    config.source_map_enabled = true

    result = described_class.new(config: config).build(
      entrypoints: { 'application' => 'application.rb' }
    )

    expect(@build_path.join('application.js').read).to include('hello from append paths')
    expect(result[:dependencies]['application']).to include(@shared_path.join('shared_message.rb').to_s)
  end

  it 'forwards append_paths and use_gems to the builder' do
    fake_builder_class = Class.new do
      class << self
        attr_accessor :instances
      end

      self.instances = []

      attr_reader :appended_paths, :built_files, :used_gems

      def initialize(**)
        @appended_paths = []
        @built_files = []
        @used_gems = []
        self.class.instances << self
      end

      def append_paths(*paths)
        appended_paths.concat(paths)
      end

      def use_gem(gem_name)
        used_gems << gem_name
      end

      def build(relative_source_file)
        built_files << relative_source_file
      end

      def to_s
        '// fake builder output'
      end

      def source_map
        Struct.new(:to_json).new('{"version":3}')
      end

      def dependent_files
        []
      end
    end

    @entrypoints_path.join('application.rb').write("puts 'noop'\n")

    config = ActiveSupport::OrderedOptions.new
    config.source_path = @source_path
    config.entrypoints_path = @entrypoints_path
    config.build_path = @build_path
    config.append_paths = [@shared_path]
    config.use_gems = %w[cannonbol browser]
    config.source_map_enabled = false

    described_class.new(config: config, builder_class: fake_builder_class).build(
      entrypoints: { 'application' => 'application.rb' }
    )

    fake_builder = fake_builder_class.instances.fetch(0)
    expect(fake_builder.appended_paths).to include(@source_path.expand_path.to_s)
    expect(fake_builder.appended_paths).to include(@entrypoints_path.expand_path.to_s)
    expect(fake_builder.appended_paths).to include(@shared_path.expand_path.to_s)
    expect(fake_builder.used_gems).to eq(%w[cannonbol browser])
    expect(fake_builder.built_files).to eq(['application.rb'])
  end
end
