require 'spec_helper'
require 'opal/rails/file_watcher'
require 'opal/rails/watch_runner'

RSpec.describe Opal::Rails::WatchRunner do
  FakeBuilderRunner = Struct.new(:results, :calls) do
    def build(entrypoints:)
      calls << entrypoints
      results.shift
    end
  end

  FakeManifest = Struct.new(:prune_calls, :write_calls) do
    def prune_stale!(outputs)
      prune_calls << outputs
    end

    def write!(outputs)
      write_calls << outputs
    end
  end

  class FakeFileWatcher
    class << self
      attr_accessor :instances
    end

    self.instances = []

    attr_reader :extra_directories, :files

    def initialize(files:, extra_directories:, &callback)
      @files = files
      @extra_directories = extra_directories
      @callback = callback
      @started = false
      @stopped = false
      self.class.instances << self
    end

    def start
      @started = true
    end

    def stop
      @stopped = true
    end

    def started?
      @started
    end

    def stopped?
      @stopped
    end
  end

  let(:source_path) { Pathname('/tmp/app/opal') }
  let(:config) do
    ActiveSupport::OrderedOptions.new.tap do |opal|
      opal.source_path = source_path
      opal.entrypoints_path = source_path
      opal.build_path = Pathname('/tmp/app/assets/builds')
      opal.entrypoints = { 'application' => 'application.rb', 'admin' => 'admin.rb' }
      opal.source_map_enabled = true
    end
  end
  let(:resolver) { instance_double(Opal::Rails::EntrypointsResolver) }
  let(:manifest) { FakeManifest.new([], []) }
  let(:builder_runner) { FakeBuilderRunner.new(results.dup, []) }
  let(:results) do
    [
      {
        outputs: %w[application.js application.js.map admin.js admin.js.map],
        dependencies: {
          'application' => ['/tmp/app/opal/application.rb', '/tmp/app/opal/shared.rb'],
          'admin' => ['/tmp/app/opal/admin.rb']
        }
      },
      {
        outputs: %w[application.js application.js.map],
        dependencies: {
          'application' => ['/tmp/app/opal/application.rb', '/tmp/app/opal/shared.rb']
        }
      },
      {
        outputs: %w[application.js application.js.map admin.js admin.js.map],
        dependencies: {
          'application' => ['/tmp/app/opal/application.rb', '/tmp/app/opal/shared.rb', '/tmp/app/opal/new_file.rb'],
          'admin' => ['/tmp/app/opal/admin.rb']
        }
      }
    ]
  end

  before do
    FakeFileWatcher.instances = []
    allow(resolver).to receive(:resolve).and_return(
      { 'application' => 'application.rb', 'admin' => 'admin.rb' },
      { 'application' => 'application.rb', 'admin' => 'admin.rb' }
    )
    allow(Opal).to receive(:dependent_files).and_return(['/tmp/opal/corelib/runtime.rb'])
  end

  it 'builds all entrypoints once and starts a watcher' do
    runner = described_class.new(
      config: config,
      resolver: resolver,
      builder_runner: builder_runner,
      manifest: manifest,
      file_watcher_class: FakeFileWatcher
    )

    runner.start!

    expect(builder_runner.calls).to eq([
                                         { 'application' => 'application.rb', 'admin' => 'admin.rb' }
                                       ])
    expect(manifest.prune_calls).to eq([
                                         %w[admin.js admin.js.map application.js application.js.map]
                                       ])
    expect(manifest.write_calls).to eq([
                                         %w[admin.js admin.js.map application.js application.js.map]
                                       ])
    expect(FakeFileWatcher.instances.last).to be_started
    expect(FakeFileWatcher.instances.last.extra_directories).to eq([
                                                                     source_path.expand_path.to_s
                                                                   ])
  end

  it 'rebuilds only affected entrypoints for known modified files' do
    runner = described_class.new(
      config: config,
      resolver: resolver,
      builder_runner: builder_runner,
      manifest: manifest,
      file_watcher_class: FakeFileWatcher
    )

    runner.start!
    runner.process_changes(modified: ['/tmp/app/opal/shared.rb'], added: [], removed: [])

    expect(builder_runner.calls).to eq([
                                         { 'application' => 'application.rb', 'admin' => 'admin.rb' },
                                         { 'application' => 'application.rb' }
                                       ])
    expect(manifest.prune_calls.length).to eq(1)
    expect(manifest.write_calls.last).to eq(%w[admin.js admin.js.map application.js application.js.map])
  end

  it 'rebuilds all entrypoints when a new file appears' do
    runner = described_class.new(
      config: config,
      resolver: resolver,
      builder_runner: builder_runner,
      manifest: manifest,
      file_watcher_class: FakeFileWatcher
    )

    runner.start!
    runner.process_changes(modified: [], added: ['/tmp/app/opal/new_file.rb'], removed: [])

    expect(builder_runner.calls).to eq([
                                         { 'application' => 'application.rb', 'admin' => 'admin.rb' },
                                         { 'application' => 'application.rb', 'admin' => 'admin.rb' }
                                       ])
    expect(manifest.prune_calls.length).to eq(2)
  end

  it 'watches configured append_paths for rebuild-triggering changes' do
    runner = described_class.new(
      config: config,
      resolver: resolver,
      builder_runner: builder_runner,
      manifest: manifest,
      file_watcher_class: FakeFileWatcher
    )

    runner.start!
    runner.process_changes(modified: [], added: ['/tmp/app/shared/opal/new_helper.rb'], removed: [])

    expect(builder_runner.calls).to eq([
                                         { 'application' => 'application.rb', 'admin' => 'admin.rb' },
                                         { 'application' => 'application.rb', 'admin' => 'admin.rb' }
                                       ])
  end

  it 're-resolves :all entrypoints and watches the dedicated entrypoints path' do
    all_config = ActiveSupport::OrderedOptions.new.tap do |opal|
      opal.source_path = Pathname('/tmp/app/opal')
      opal.entrypoints_path = Pathname('/tmp/app/opal/entrypoints')
      opal.build_path = Pathname('/tmp/app/assets/builds')
      opal.entrypoints = :all
      opal.append_paths = []
      opal.source_map_enabled = true
    end

    all_resolver = instance_double(Opal::Rails::EntrypointsResolver)
    allow(all_resolver).to receive(:resolve).and_return(
      { 'application' => 'application.rb' },
      { 'application' => 'application.rb', 'dashboard' => 'dashboard.rb' }
    )

    all_builder_runner = FakeBuilderRunner.new(
      [
        {
          outputs: %w[application.js application.js.map],
          dependencies: {
            'application' => ['/tmp/app/opal/entrypoints/application.rb', '/tmp/app/opal/shared.rb']
          }
        },
        {
          outputs: %w[application.js application.js.map dashboard.js dashboard.js.map],
          dependencies: {
            'application' => ['/tmp/app/opal/entrypoints/application.rb', '/tmp/app/opal/shared.rb'],
            'dashboard' => ['/tmp/app/opal/entrypoints/dashboard.rb']
          }
        }
      ],
      []
    )

    all_manifest = FakeManifest.new([], [])

    runner = described_class.new(
      config: all_config,
      resolver: all_resolver,
      builder_runner: all_builder_runner,
      manifest: all_manifest,
      file_watcher_class: FakeFileWatcher
    )

    runner.start!
    expect(FakeFileWatcher.instances.last.extra_directories).to eq([
                                                                     '/tmp/app/opal',
                                                                     '/tmp/app/opal/entrypoints'
                                                                   ])

    runner.process_changes(modified: [], added: ['/tmp/app/opal/entrypoints/dashboard.rb'], removed: [])

    expect(all_builder_runner.calls).to eq([
                                             { 'application' => 'application.rb' },
                                             { 'application' => 'application.rb', 'dashboard' => 'dashboard.rb' }
                                           ])
    expect(all_manifest.prune_calls).to eq([
                                             %w[application.js application.js.map],
                                             %w[application.js application.js.map dashboard.js dashboard.js.map]
                                           ])
    expect(all_manifest.write_calls.last).to eq(%w[application.js application.js.map dashboard.js dashboard.js.map])
  end

  it 'reports build errors without crashing the watcher' do
    error_output = StringIO.new

    failing_builder = FakeBuilderRunner.new(
      [
        results.first.dup,
        nil # will not be reached; the second build raises
      ],
      []
    )
    allow(failing_builder).to receive(:build).and_call_original
    allow(failing_builder).to receive(:build).with(entrypoints: { 'application' => 'application.rb' })
                                             .and_raise(StandardError, 'syntax error in application.rb')

    runner = described_class.new(
      config: config,
      resolver: resolver,
      builder_runner: failing_builder,
      manifest: manifest,
      file_watcher_class: FakeFileWatcher,
      error_output: error_output
    )

    runner.start!
    expect { runner.process_changes(modified: ['/tmp/app/opal/shared.rb'], added: [], removed: []) }.not_to raise_error
    expect(error_output.string).to include('Opal build error: syntax error in application.rb')
    expect(FakeFileWatcher.instances.last).to be_started
  end
end
