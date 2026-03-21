require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe Opal::Rails::EntrypointsResolver do
  around do |example|
    Dir.mktmpdir do |dir|
      @entrypoints_path = Pathname(dir)
      example.run
    end
  end

  it 'resolves an explicit mapping' do
    @entrypoints_path.join('application.rb').write("puts 'hello'\n")

    resolver = described_class.new(
      entrypoints_path: @entrypoints_path,
      entrypoints: { 'application' => 'application.rb' }
    )

    expect(resolver.resolve).to eq('application' => 'application.rb')
  end

  it 'rejects missing explicit files' do
    resolver = described_class.new(
      entrypoints_path: @entrypoints_path,
      entrypoints: { 'application' => 'application.rb' }
    )

    expect { resolver.resolve }
      .to raise_error(Opal::Rails::MissingEntrypointError, /application\.rb/)
  end

  it 'resolves top-level ruby files when entrypoints is :all' do
    @entrypoints_path.join('zeta.rb').write("puts 'zeta'\n")
    @entrypoints_path.join('alpha.rb').write("puts 'alpha'\n")
    FileUtils.mkdir_p(@entrypoints_path.join('nested'))
    @entrypoints_path.join('nested/ignored.rb').write("puts 'ignored'\n")

    resolver = described_class.new(
      entrypoints_path: @entrypoints_path,
      entrypoints: :all
    )

    expect(resolver.resolve).to eq(
      'alpha' => 'alpha.rb',
      'zeta' => 'zeta.rb'
    )
  end
end
