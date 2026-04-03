require 'spec_helper'

RSpec.describe Opal::Rails::PathSetup do
  FakeAssetsConfig = Struct.new(:excluded_paths)
  FakeConfig = Struct.new(:opal, :eager_load_paths, :assets)
  FakeApp = Struct.new(:root, :config)

  class FakeAutoloader
    attr_reader :ignored_paths

    def initialize
      @ignored_paths = []
    end

    def ignore(path)
      @ignored_paths << path
    end
  end

  around do |example|
    Dir.mktmpdir do |dir|
      @root = Pathname(dir)
      FileUtils.mkdir_p(@root.join('app/assets/opal'))
      FileUtils.mkdir_p(@root.join('app/views'))
      FileUtils.mkdir_p(@root.join('app/models'))
      example.run
    end
  end

  it 'defaults to app/opal and ignores it in autoloaders' do
    config = FakeConfig.new(ActiveSupport::OrderedOptions.new, [
                              @root.join('app/assets').to_s,
                              @root.join('app/views').to_s,
                              @root.join('app/opal').to_s,
                              @root.join('app/models').to_s
                            ], FakeAssetsConfig.new([]))

    app = FakeApp.new(@root, config)
    autoloaders = [FakeAutoloader.new, FakeAutoloader.new]

    described_class.apply!(app, autoloaders: autoloaders)

    expect(config.opal.source_path).to eq(@root.join('app/opal'))
    expect(config.opal.entrypoints_path).to eq(@root.join('app/opal'))
    expect(config.opal.build_path).to eq(@root.join('app/assets/builds'))
    expect(config.eager_load_paths).to eq([
                                            @root.join('app/models').to_s
                                          ])
    expect(autoloaders.map(&:ignored_paths)).to all(include(@root.join('app/opal')))
    expect(config.assets.excluded_paths).to be_empty
  end

  it 'leaves app/assets/opal visible to the asset pipeline without autoloader ignores' do
    config = FakeConfig.new(ActiveSupport::OrderedOptions.new, [
                              @root.join('app/assets').to_s,
                              @root.join('app/views').to_s,
                              @root.join('app/models').to_s
                            ], FakeAssetsConfig.new([]))
    config.opal.source_path = @root.join('app/assets/opal')

    app = FakeApp.new(@root, config)
    autoloaders = [FakeAutoloader.new]

    2.times { described_class.apply!(app, autoloaders: autoloaders) }

    expect(config.opal.entrypoints_path).to eq(@root.join('app/assets/opal'))
    expect(config.opal.build_path).to eq(@root.join('app/assets/builds'))
    expect(config.assets.excluded_paths).to be_empty
    expect(autoloaders.first.ignored_paths).to be_empty
  end
end
