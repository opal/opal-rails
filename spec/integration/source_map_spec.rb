require 'spec_helper'
require 'opal/source_map'

describe Opal::SourceMap do
  let(:js_asset_path) { '/assets/source_map_example.js' }

  before do
    expect(Rails.application.config.opal.source_map_enabled).to be_truthy
    get js_asset_path
  end

  let(:map_path) { extract_map_path(response) }

  let(:map_body) do
    get map_path
    expect(response).to be_success, "url: #{map_path}\nstatus: #{response.status}"
    response.body
  end

  let(:map) { JSON.parse(map_body) }

  it 'has the source map header or magic comment' do
    expect(extract_map_path(response)).to be_present
  end

  it "the map is a valid json" do
    get map_path
    %w[sources mappings].each do |key|
      expect(map_body[key]).to be_present
    end
  end

  def extract_map_path response
    source_map_regexp = %r{^//[@#] sourceMappingURL=([^\n]+)}
    map_path = (response.headers['X-SourceMap'] ||
                 response.body.scan(source_map_regexp).
                 flatten.first.to_s.strip)
    File.join(File.dirname(js_asset_path), map_path) if map_path
  end

end
