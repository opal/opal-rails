require 'spec_helper'
require 'opal/source_map'

describe Opal::SourceMap do
  before do
    expect(Rails.application.config.opal.source_map_enabled).to be_true
    get '/assets/source_map_example.js'
  end

  let(:map_url) { extract_map_url(response) }

  let(:map_body) do
    get map_url
    raise "#{response.status}\n\n#{response.body}" unless response.success?
    response.body
  end

  let(:map) { JSON.parse(map_body) }

  it 'has the source map header or magic comment' do
    expect(extract_map_url(response)).to be_present
  end

  it "the map is a valid json" do
    %w[sources mappings].each do |key|
      expect(map_body[key]).to be_present
    end
  end

  it "points to a file on the disk" do
    path = map['sources'].first
    pathname = Pathname(path.gsub(%r{^file\://}, ''))
    expect(pathname.exist?).to be_true
  end


  def extract_map_url response
    response.headers['X-SourceMap'] or
    response.body.scan(%r{^//@ sourceMappingURL=([^\n]+)}).flatten.first.strip
  end

end
