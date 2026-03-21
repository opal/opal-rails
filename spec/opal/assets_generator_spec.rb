require 'rails/generators'
require 'generators/opal/assets/assets_generator'

RSpec.describe Opal::AssetsGenerator do
  around do |example|
    Dir.mktmpdir do |dir|
      @root = Pathname(dir)
      FileUtils.mkdir_p(@root.join('app'))
      example.run
    end
  end

  it 'generates a build-based asset under app/opal by default' do
    described_class.start(['dashboard'], destination_root: @root.to_s)

    generated_file = @root.join('app/opal/dashboard.rb')

    expect(generated_file).to exist
    expect(generated_file.read).to include('Require this file from `app/opal/application.rb`')
    expect(generated_file.read).to include('class DashboardView')
  end

  it 'reuses app/assets/opal for migration-friendly layouts' do
    FileUtils.mkdir_p(@root.join('app/assets/opal'))

    described_class.start(['dashboard'], destination_root: @root.to_s)

    expect(@root.join('app/assets/opal/dashboard.rb')).to exist
    expect(@root.join('app/opal/dashboard.rb')).not_to exist
  end
end
