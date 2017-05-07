require 'spec_helper'

describe OpalHelper, type: :helper do
  # subject(:helper) { double(javascript_include_tag: '<super>').extend described_class }

  describe '#opal_tag' do
    it 'compiles to js' do
      allow(helper).to receive(:javascript_tag) { |code| code }
      ruby_code = 'puts 5'

      expect(Opal::Compiler).to receive(:new)
        .with(ruby_code, hash_including(requirable: false))
        .and_call_original

      expect(helper.opal_tag(ruby_code)).to include('self.$puts(5)')
    end
  end

  specify '#javascript_include_tag' do
    # sprockets-rails v3 sets Rails.application.assets to nil in production mode
    allow(Rails.application).to receive(:assets).and_return(nil)

    loading_code = %Q{Opal.load("application");}
    escaped_loading_code = ERB::Util.h loading_code

    expect(helper.javascript_include_tag('application', debug: true)).to  include(escaped_loading_code)
    expect(helper.javascript_include_tag('application', debug: false)).to include(escaped_loading_code)
    expect(helper.javascript_include_tag('application', skip_opal_loader: true)).not_to include(escaped_loading_code)
    expect(helper.javascript_include_tag('application', skip_opal_loader: true)).not_to include(escaped_loading_code)

    expect(helper.javascript_include_tag('application', force_opal_loader_tag: true, debug: true)).to  include(loading_code)
    expect(helper.javascript_include_tag('application', force_opal_loader_tag: true, debug: false)).to include(loading_code)
    expect(helper.javascript_include_tag('application', force_opal_loader_tag: true, skip_opal_loader: true)).not_to include(loading_code)
    expect(helper.javascript_include_tag('application', force_opal_loader_tag: true, skip_opal_loader: true)).not_to include(loading_code)
  end
end
