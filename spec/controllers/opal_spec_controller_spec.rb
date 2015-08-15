require 'spec_helper'

RSpec.describe OpalSpecController, :type => :controller do
  describe 'GET run' do
    before do
      get :run
    end
    
    it 'assigns assets' do
      expect(assigns(:assets)).to_not be_empty
    end
    
    it 'assigns spec files' do
      expect(assigns(:spec_files)).to include(/.*example_spec.js.rb$/,
                                              /.*requires_opal_spec.js.rb$/,
                                              /.*subdirectory\/other_spec.js.rb$/)
    end
    
    it 'assigns pattern' do
      expect(assigns(:using_pattern)).to eq false
    end
    
    it 'assigns main_code' do
      code = <<-CODE
require "example_spec"
require "requires_opal_spec"
require "subdirectory/other_spec"
Opal::RSpec::Runner.autorun
CODE
    expect(assigns(:main_code)).to eq code.strip
    end
  end
end
