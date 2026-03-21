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

      FileUtils.mkdir_p(@source_path)
      FileUtils.mkdir_p(@entrypoints_path)
      FileUtils.mkdir_p(@build_path)

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
end
