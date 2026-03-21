require 'spec_helper'

RSpec.describe BrowserSupport do
  describe '.path' do
    it 'prefers an executable BROWSER_PATH override' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('BROWSER_PATH').and_return('/custom/browser')
      allow(File).to receive(:executable?).and_call_original
      allow(File).to receive(:executable?).with('/custom/browser').and_return(true)

      expect(described_class.path).to eq('/custom/browser')
    end

    it 'falls back to known absolute browser paths' do
      stub_const('BrowserSupport::ABSOLUTE_BROWSER_CANDIDATES', ['/custom/headless_shell'])
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('BROWSER_PATH').and_return(nil)
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('PATH', '').and_return('')
      allow(File).to receive(:executable?).and_call_original
      allow(File).to receive(:executable?).with('/custom/headless_shell').and_return(true)

      expect(described_class.path).to eq('/custom/headless_shell')
    end
  end

  describe '.available?' do
    it 'reflects whether a browser path was found' do
      allow(described_class).to receive(:path).and_return('/custom/browser')
      expect(described_class.available?).to eq(true)

      allow(described_class).to receive(:path).and_return(nil)
      expect(described_class.available?).to eq(false)
    end
  end
end
