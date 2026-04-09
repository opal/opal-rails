require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe Opal::Rails::OutputsManifest do
  around do |example|
    Dir.mktmpdir do |dir|
      @build_path = Pathname(dir)
      FileUtils.mkdir_p(@build_path)
      example.run
    end
  end

  it 'prunes only previously tracked outputs' do
    @build_path.join('application.js').write('old')
    @build_path.join('application.js.map').write('old map')
    @build_path.join('unrelated.js').write('keep me')

    manifest = described_class.new(build_path: @build_path)
    manifest.write!(%w[application.js application.js.map])

    manifest.prune_stale!(['application.js'])
    manifest.write!(['application.js'])

    expect(@build_path.join('application.js')).to exist
    expect(@build_path.join('application.js.map')).not_to exist
    expect(@build_path.join('unrelated.js')).to exist
  end

  it 'ignores paths that escape the build directory' do
    outside_file = @build_path.join('..', 'outside.txt')
    outside_file.write('should survive')

    manifest = described_class.new(build_path: @build_path)
    manifest.write!(['../outside.txt', 'application.js'])

    @build_path.join('application.js').write('app')

    manifest.prune_stale!(['application.js'])

    expect(outside_file).to exist
    expect(@build_path.join('application.js')).to exist
  end
end
