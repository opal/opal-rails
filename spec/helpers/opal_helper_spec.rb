require 'spec_helper'

# We need the view type because helpers specs are to are too minimalistic
# and are missing some initialization stuff.
describe OpalHelper, :js, type: :view do
  let(:helper) { view }

  describe '#opal_tag' do
    let(:ruby_code) { 'puts 5' }
    let(:compiled_ruby_code) { 'self.$puts(5)' }
    let(:html_options) { { async: true } }
    before do
      allow(helper).to receive(:javascript_tag).and_call_original
      allow(Opal::Compiler).to receive(:new)
        .with(ruby_code, hash_including(requirable: false))
        .and_call_original
    end

    context 'when the ruby code is passed inline' do
      it 'compiles the ruby code to js' do
        expect(helper.opal_tag(ruby_code)).to include(compiled_ruby_code)
      end

      it 'passes the html_options to the javascript_tag' do
        helper.opal_tag(ruby_code, html_options)
        expect(helper).to have_received(:javascript_tag).with(html_options)
      end
    end

    context 'when the ruby code is passed as a block' do
      it 'compiles the block to js' do
        expect(helper.opal_tag { ruby_code }).to include(compiled_ruby_code)
      end

      it 'uses the options as the first argument' do
        aggregate_failures do
          expect(helper.opal_tag(html_options) { ruby_code }).to include(compiled_ruby_code)
          expect(helper).to have_received(:javascript_tag).with(html_options)
        end
      end
    end
  end

  specify '#javascript_include_tag' do
    # sprockets-rails v3 sets Rails.application.assets to nil in production mode
    allow(Rails.application).to receive(:assets).and_return(nil)

    loading_code = [
      %<if(window.Opal && Opal.modules["application"]){Opal.loaded(typeof(OpalLoaded) === "undefined" ? [] : OpalLoaded);>,
      %<Opal.require("application");}>,
    ].join("\n")

    escaped_loading_code = ERB::Util.h loading_code
    loading_code_in_script_tag = [
      %(<script>), %(//<![CDATA[), loading_code, %(//]]>), %(</script>),
    ].join("\n")

    expect(helper.javascript_include_tag('application', debug: true)).to include(loading_code_in_script_tag)
    expect(helper.javascript_include_tag('application', debug: true)).not_to include(escaped_loading_code)

    expect(helper.javascript_include_tag('application', debug: false)).to include(escaped_loading_code)
    expect(helper.javascript_include_tag('application', debug: false)).not_to include(loading_code_in_script_tag)

    expect(helper.javascript_include_tag('application', skip_opal_loader: true)).not_to include(escaped_loading_code)
    expect(helper.javascript_include_tag('application', skip_opal_loader: false)).to include(loading_code_in_script_tag)

    expect(helper.javascript_include_tag('application', force_opal_loader_tag: true, debug: true)).to include(loading_code_in_script_tag)
    expect(helper.javascript_include_tag('application', force_opal_loader_tag: true, debug: false)).to include(loading_code_in_script_tag)

    expect(helper.javascript_include_tag('application', force_opal_loader_tag: true, skip_opal_loader: true)).not_to include(escaped_loading_code)
    expect(helper.javascript_include_tag('application', force_opal_loader_tag: true, skip_opal_loader: true)).to include(loading_code_in_script_tag)
  end
end
