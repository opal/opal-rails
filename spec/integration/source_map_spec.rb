require 'base64'
require 'spec_helper'
require 'opal/source_map'

describe Opal::SourceMap do
  let(:js_asset_path) { '/assets/source_map_example.debug.js' }

  before do
    expect(Rails.application.config.opal.source_map_enabled).to be_truthy
    expect(Rails.application.config.assets.compile).to be_truthy
    expect(Rails.application.assets).to be_present
    expect(Rails.application.config.assets.debug).to be_truthy
  end

  let(:map_body) do
    get js_asset_path

    inline_map_prefix = '//# sourceMappingURL=data:application/json;base64,'

    if response.body.lines.last.start_with? inline_map_prefix
      Base64.decode64(response.body.lines.last.split(inline_map_prefix, 2)[1])
    else
      source_map_regexp = %r{^//[@#] sourceMappingURL=([^\n]+)}
      header_map_path = response.headers['X-SourceMap'].presence
      comment_map_path = response.body.scan(source_map_regexp).flatten.first.to_s.strip.presence

      map_path = header_map_path || comment_map_path

      get URI.join("http://example.com/", js_asset_path, map_path).path
      expect(response).to be_successful, "url: #{map_path}\nstatus: #{response.status}"
      response.body
    end
  end

  let(:map) { JSON.parse(map_body, symbolize_names: true) }

  it 'has the source map be there' do
    expect(map).to be_present
    expect(map[:sections].last[:map][:sources]).to be_present
    expect(map[:sections].last[:map][:mappings]).to be_present
  end
end
