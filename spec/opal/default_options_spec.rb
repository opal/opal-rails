require 'spec_helper'
require 'opal/default_options'

describe Opal::Parser do
  let(:default_options) { {:method_missing => false} }
  let(:source) { 'puts "ciao"' }
  before { Opal.default_options = default_options }

  it 'fetches default options defined in the Opal module' do
    described_class.any_instance.should_receive(:parse).with(source, default_options)
    Opal.parse(source)
  end
end
