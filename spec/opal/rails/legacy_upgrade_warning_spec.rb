require 'spec_helper'

RSpec.describe Opal::Rails::LegacyUpgradeWarning do
  around do |example|
    Dir.mktmpdir do |dir|
      @root = Pathname(dir)
      FileUtils.mkdir_p(@root.join('config/initializers'))
      FileUtils.mkdir_p(@root.join('app/assets/config'))
      example.run
    end
  end

  it 'warns for the reproduced 2.x generator layout' do
    @root.join('config/initializers/opal.rb').write(<<~RUBY)
      Rails.application.configure do
        config.opal.method_missing_enabled = true
        config.opal.const_missing_enabled = true
        config.opal.arity_check_enabled = false
        config.opal.freezing_stubs_enabled = true
        config.opal.dynamic_require_severity = :warning
        config.opal.assigns_in_templates = false
      end
    RUBY
    @root.join('app/assets/config/manifest.js').write("//= link_directory ../javascript .js\n")
    FileUtils.mkdir_p(@root.join('app/assets/javascript'))
    @root.join('app/assets/javascript/application.js.rb').write("require 'opal'\n")

    warning = described_class.warning_for(@root)

    expect(warning).to include('likely 2.x application layout')
    expect(warning).to include('Pin `opal-rails` to the 2.0 series')
    expect(warning).to include('config.opal.suppress_legacy_upgrade_warning = true')
    expect(warning).to include('config/initializers/opal.rb still uses legacy 2.x runtime settings')
    expect(warning).to include('legacy Opal asset entrypoint present at app/assets/javascript/application.js.rb')
    expect(warning).to include('app/assets/config/manifest.js still links the legacy javascript asset tree')
    expect(warning).to include('expected 3.x source root app/opal is missing')
  end

  it 'does not warn for a build-based 3.x layout' do
    @root.join('config/initializers/opal.rb').write(<<~RUBY)
      Rails.application.configure do
        config.opal.source_path = Rails.root.join('app/opal')
        config.opal.entrypoints_path = config.opal.source_path
        config.opal.build_path = Rails.root.join('app/assets/builds')
        config.opal.entrypoints = { 'application' => 'application.rb' }
      end
    RUBY
    FileUtils.mkdir_p(@root.join('app/opal'))

    expect(described_class.warning_for(@root)).to be_nil
  end

  it 'does not warn from a single weak signal' do
    @root.join('config/initializers/opal.rb').write(<<~RUBY)
      Rails.application.configure do
        config.opal.method_missing_enabled = true
      end
    RUBY

    expect(described_class.warning_for(@root)).to be_nil
  end

  it 'writes the warning to the provided output' do
    @root.join('config/initializers/opal.rb').write(<<~RUBY)
      Rails.application.configure do
        config.opal.method_missing_enabled = true
        config.opal.const_missing_enabled = true
      end
    RUBY
    @root.join('app/assets/config/manifest.js').write("//= link_directory ../javascript .js\n")

    output = StringIO.new

    expect(described_class.warn_if_needed(Struct.new(:root).new(@root), output: output)).to be(true)
    expect(output.string).to include('likely 2.x application layout')
  end

  it 'does not write the warning when suppression is enabled' do
    @root.join('config/initializers/opal.rb').write(<<~RUBY)
      Rails.application.configure do
        config.opal.method_missing_enabled = true
        config.opal.const_missing_enabled = true
      end
    RUBY
    @root.join('app/assets/config/manifest.js').write("//= link_directory ../javascript .js\n")

    output = StringIO.new
    app = Struct.new(:root, :config).new(@root,
                                         Struct.new(:opal).new(Struct.new(:suppress_legacy_upgrade_warning).new(true)))

    expect(described_class.warn_if_needed(app, output: output)).to be(false)
    expect(output.string).to be_empty
  end
end
