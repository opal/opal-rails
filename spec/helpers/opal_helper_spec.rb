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
end
