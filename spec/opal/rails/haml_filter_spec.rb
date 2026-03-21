require 'open3'
require 'rbconfig'
require 'opal/rails/haml_filter'

RSpec.describe 'Opal Haml filter loader' do
  let(:project_root) { File.expand_path('../../..', __dir__) }

  def run_loader_with_version(version)
    script = <<~RUBY
      require 'haml'
      Haml.send(:remove_const, :VERSION)
      Haml::VERSION = #{version.inspect}
      require 'opal/rails/haml_filter'
    RUBY

    Open3.capture3('bundle', '_4.0.3_', 'exec', RbConfig.ruby, '-I', File.join(project_root, 'lib'), '-e', script,
                   chdir: project_root)
  end

  it 'rejects Haml 5.x' do
    _stdout, stderr, status = run_loader_with_version('5.2.2')

    expect(status).not_to be_success
    expect(stderr).to include('Haml 6 or newer')
  end

  it 'loads on Haml 6+' do
    _stdout, _, status = run_loader_with_version('6.3.0')

    expect(status).to be_success
  end

  it 'returns the module script mime type when ESM is enabled' do
    original_esm = Opal::Config.esm
    Opal::Config.esm = true

    expect(Haml::Filters::Opal.allocate.mime_type).to eq('module')
  ensure
    Opal::Config.esm = original_esm
  end
end
