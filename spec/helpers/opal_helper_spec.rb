require 'spec_helper'

describe OpalHelper do
  subject(:helper) { double.extend described_class }

  describe '#opal_tag' do
    it 'compiles to js' do
      allow(helper).to receive(:javascript_tag) { |code| code }
      ruby_code = 'puts 5'

      expect(Opal::Compiler).to receive(:new)
        .with(ruby_code, hash_including(requirable: false))
        .and_call_original

      expect(helper.opal_tag(ruby_code)).to include('.$puts(')
    end
  end
end
