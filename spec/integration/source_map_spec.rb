require 'spec_helper'
require 'opal/source_map'

describe Opal::SourceMap do
  before { get '/assets/source_map_example.js' }

  let(:map_body) do
    get response.headers['X-SourceMap']
    response.body
  end

  let(:map) { JSON.parse(map_body) }

  it 'has the source map header' do
    expect(response.headers['X-SourceMap']).to be_present
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

end
