require 'spec_helper'
require 'rake'
require 'tmpdir'
require 'fileutils'

RSpec.describe 'opal:build task' do
  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?('opal:build')
  end

  around do |example|
    Dir.mktmpdir do |dir|
      root = Pathname(dir)
      source_path = root.join('app/opal')
      build_path = root.join('app/assets/builds')
      FileUtils.mkdir_p(source_path)
      FileUtils.mkdir_p(build_path)

      source_path.join('application.rb').write("require 'opal'\nputs 'built from task'\n")

      config = Rails.application.config.opal
      original_source_path = config.source_path
      original_entrypoints_path = config.entrypoints_path
      original_build_path = config.build_path
      original_entrypoints = config.entrypoints
      original_append_paths = config.append_paths
      original_use_gems = config.use_gems
      original_source_map_enabled = config.source_map_enabled if config.respond_to?(:source_map_enabled)

      config.source_path = source_path
      config.entrypoints_path = source_path
      config.build_path = build_path
      config.entrypoints = { 'application' => 'application.rb' }
      config.append_paths = []
      config.use_gems = []
      config.source_map_enabled = true

      example.run
    ensure
      config.source_path = original_source_path
      config.entrypoints_path = original_entrypoints_path
      config.build_path = original_build_path
      config.entrypoints = original_entrypoints
      config.append_paths = original_append_paths
      config.use_gems = original_use_gems
      config.source_map_enabled = original_source_map_enabled if config.respond_to?(:source_map_enabled)
    end
  end

  it 'builds assets and writes an ownership manifest' do
    Rake::Task['opal:build'].reenable
    Rake::Task['opal:build'].invoke

    build_path = Pathname(Rails.application.config.opal.build_path)

    expect(build_path.join('application.js')).to exist
    expect(build_path.join('application.js.map')).to exist
    expect(build_path.join('.opal-build-manifest.json').read).to include('application.js')
  end

  it 'builds and prunes bulk-discovered entrypoints in :all mode' do
    Dir.mktmpdir do |dir|
      root = Pathname(dir)
      source_path = root.join('app/assets/opal')
      build_path = root.join('app/assets/builds')
      FileUtils.mkdir_p(source_path.join('nested'))
      FileUtils.mkdir_p(build_path)

      source_path.join('application.rb').write("require 'opal'\nputs 'app entrypoint'\n")
      source_path.join('dashboard.rb').write("require 'opal'\nputs 'dashboard entrypoint'\n")
      source_path.join('nested/ignored.rb').write("require 'opal'\nputs 'ignore me'\n")

      config = Rails.application.config.opal
      original_source_path = config.source_path
      original_entrypoints_path = config.entrypoints_path
      original_build_path = config.build_path
      original_entrypoints = config.entrypoints
      original_append_paths = config.append_paths
      original_use_gems = config.use_gems
      original_source_map_enabled = config.source_map_enabled if config.respond_to?(:source_map_enabled)

      config.source_path = source_path
      config.entrypoints_path = source_path
      config.build_path = build_path
      config.entrypoints = :all
      config.append_paths = []
      config.use_gems = []
      config.source_map_enabled = true

      Rake::Task['opal:build'].reenable
      Rake::Task['opal:build'].invoke

      expect(build_path.join('application.js')).to exist
      expect(build_path.join('dashboard.js')).to exist
      expect(build_path.join('nested.js')).not_to exist
      expect(build_path.join('.opal-build-manifest.json').read).to include('dashboard.js')

      source_path.join('dashboard.rb').delete

      Rake::Task['opal:build'].reenable
      Rake::Task['opal:build'].invoke

      expect(build_path.join('application.js')).to exist
      expect(build_path.join('dashboard.js')).not_to exist
      expect(build_path.join('.opal-build-manifest.json').read).not_to include('dashboard.js')
    ensure
      config.source_path = original_source_path
      config.entrypoints_path = original_entrypoints_path
      config.build_path = original_build_path
      config.entrypoints = original_entrypoints
      config.append_paths = original_append_paths
      config.use_gems = original_use_gems
      config.source_map_enabled = original_source_map_enabled if config.respond_to?(:source_map_enabled)
    end
  end
end
