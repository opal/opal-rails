require 'spec_helper'

RSpec.describe OpalSpecController, :type => :controller do
  describe 'GET run' do    
    RSpec.shared_examples :assigns_common do
      it 'assigns assets' do
        expect(assigns(:assets)).to_not be_empty
      end
      
      it 'sets asset rollup' do
        if Rails.configuration.assets.debug
          expect(assigns(:rolled_up)).to (Rails.configuration.assets.debug ? be_nil : be_not_empty)
        end
      end
    end
    
    context 'no pattern' do
      before do
        get :run
      end
      
      include_examples :assigns_common
      
      it 'assigns spec files' do
        expect(assigns(:spec_files)).to include(/.*example_spec.js.rb$/,
                                                /.*requires_opal_spec.js.rb$/,
                                                /.*subdirectory\/other_spec.js.rb$/)
      end
    
      it 'assigns pattern' do
        expect(assigns(:pattern)).to eq nil
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
        
    context 'pattern' do
      before do
        get :run, pattern: 'example_spec'
      end
      
      include_examples :assigns_common
      
      it 'assigns spec files' do
        expect(assigns(:spec_files)).to include(/.*example_spec.js.rb$/)
        expect(assigns(:spec_files)).to_not include(/.*requires_opal_spec.js.rb$/,
                                                    /.*subdirectory\/other_spec.js.rb$/)
      end
    
      it 'assigns pattern' do
        expect(assigns(:pattern)).to eq 'example_spec'
      end
      
      it 'assigns main_code' do
        code = <<-CODE
require "example_spec"
Opal::RSpec::Runner.autorun
CODE
        expect(assigns(:main_code)).to eq code.strip
      end      
    end    
  end
end
