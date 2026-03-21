require 'spec_helper'
require 'rails/generators'
require 'tmpdir'
require 'fileutils'
require 'generators/opal/install/install_generator'

RSpec.describe Opal::InstallGenerator do
  around do |example|
    Dir.mktmpdir do |dir|
      root = Pathname(dir)
      FileUtils.mkdir_p(root.join('app/views/layouts'))
      FileUtils.mkdir_p(root.join('app/assets/config'))
      FileUtils.mkdir_p(root.join('config/environments'))
      root.join('app/views/layouts/application.html.erb').write("<html>\n  <head>\n  </head>\n</html>\n")
      root.join('app/assets/config/manifest.js').write("//= link_tree ../images\n")
      root.join('config/environments/test.rb').write("Rails.application.configure do\nend\n")
      root.join('.gitignore').write('')

      @root = root
      example.run
    end
  end

  it 'creates a build-based install in app/opal and wires Sprockets test assets to builds' do
    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('app/opal/application.rb')).to exist
    expect(@root.join('config/initializers/opal.rb').read).to include("config.opal.source_path = Rails.root.join('app/opal')")
    expect(@root.join('app/assets/builds/.keep')).to exist
    expect(@root.join('Procfile.dev').read).to include('opal: bin/rails opal:watch')
    expect(@root.join('bin/dev')).to exist
    expect(@root.join('bin/dev').read).to include('foreman start -f Procfile.dev "$@"')
    expect(@root.join('.gitignore').read).to include('/app/assets/builds/*')
    expect(@root.join('app/views/layouts/application.html.erb').read).to include('javascript_include_tag "application", "data-turbo-track": "reload"')
    expect(@root.join('app/assets/config/manifest.js').read).to eq("//= link_tree ../images\n//= link_directory ../builds .js\n//= link_directory ../builds .map\n")
    expect(@root.join('config/environments/test.rb').read).to eq("Rails.application.configure do\n  config.assets.debug = true\nend\n")
  end

  it 'keeps app/assets/opal as the source root for migration installs' do
    FileUtils.mkdir_p(@root.join('app/assets/opal'))

    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('app/assets/opal/application.rb')).to exist
    expect(@root.join('config/initializers/opal.rb').read).to include("config.opal.source_path = Rails.root.join('app/assets/opal')")
  end

  it 'uses :all for existing multi-entrypoint migration layouts without adding an application include' do
    FileUtils.mkdir_p(@root.join('app/assets/opal'))
    @root.join('app/assets/opal/sample_selector.rb').write("require 'opal'\n")
    @root.join('app/assets/opal/address_form.rb').write("require 'opal'\n")

    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('app/assets/opal/application.rb')).not_to exist
    expect(@root.join('config/initializers/opal.rb').read).to include('config.opal.entrypoints = :all')
    expect(@root.join('app/views/layouts/application.html.erb').read).not_to include('javascript_include_tag "application"')
  end

  it 'uses an explicit opal asset name when the host app already has application.js' do
    FileUtils.mkdir_p(@root.join('app/javascript'))
    @root.join('app/javascript/application.js').write("console.log('existing app asset')\n")

    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('app/opal/application.rb')).to exist
    expect(@root.join('config/initializers/opal.rb').read).to include("config.opal.entrypoints = { 'opal' => 'application.rb' }")
    expect(@root.join('app/views/layouts/application.html.erb').read).to include('javascript_include_tag "opal", "data-turbo-track": "reload"')
  end

  it 'adds the opal include alongside an existing application include in mixed-stack apps' do
    FileUtils.mkdir_p(@root.join('app/javascript'))
    @root.join('app/javascript/application.js').write("console.log('existing app asset')\n")
    @root.join('app/views/layouts/application.html.erb').write(<<~ERB)
      <html>
        <head>
          <%= javascript_include_tag "application", "data-turbo-track": "reload" %>
        </head>
      </html>
    ERB

    described_class.start([], destination_root: @root.to_s)

    layout = @root.join('app/views/layouts/application.html.erb').read
    expect(layout.scan('javascript_include_tag "application"').length).to eq(1)
    expect(layout.scan('javascript_include_tag "opal"').length).to eq(1)
  end

  it 'does not overwrite an existing application entrypoint' do
    FileUtils.mkdir_p(@root.join('app/opal'))
    @root.join('app/opal/application.rb').write("puts 'keep me'\n")

    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('app/opal/application.rb').read).to eq("puts 'keep me'\n")
  end

  it 'does not add a duplicate application include when the layout already has one' do
    @root.join('app/views/layouts/application.html.erb').write(<<~ERB)
      <html>
        <head>
          <%= javascript_include_tag "application", "data-turbo-track": "reload" %>
        </head>
      </html>
    ERB

    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('app/views/layouts/application.html.erb').read.scan('javascript_include_tag "application"').length).to eq(1)
  end

  it 'does not overwrite an existing bin/dev that already uses Procfile.dev' do
    FileUtils.mkdir_p(@root.join('bin'))
    @root.join('bin/dev').write("#!/usr/bin/env sh\nforeman start -f Procfile.dev\n")

    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('bin/dev').read).to eq("#!/usr/bin/env sh\nforeman start -f Procfile.dev\n")
  end

  it 'replaces bin/dev when it does not use Procfile.dev' do
    FileUtils.mkdir_p(@root.join('bin'))
    @root.join('bin/dev').write("#!/usr/bin/env ruby\nexec \"./bin/rails\", \"server\"\n")

    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('bin/dev').read).to include('foreman start -f Procfile.dev "$@"')
  end

  it 'does not duplicate build links or test asset debug settings' do
    @root.join('app/assets/config/manifest.js').write("//= link_tree ../images\n//= link_directory ../builds .js\n//= link_directory ../builds .map\n")
    @root.join('config/environments/test.rb').write("Rails.application.configure do\n  config.assets.debug = true\nend\n")

    described_class.start([], destination_root: @root.to_s)

    expect(@root.join('app/assets/config/manifest.js').read.scan('../builds .js').length).to eq(1)
    expect(@root.join('app/assets/config/manifest.js').read.scan('../builds .map').length).to eq(1)
    expect(@root.join('config/environments/test.rb').read.scan('config.assets.debug = true').length).to eq(1)
  end
end
