require 'spec_helper'

describe 'Rake task' do
  around do |ex|
    Dir.chdir 'test_app' do
      ex.run
    end
  end

  subject { `rake opal:spec` }

  it { is_expected.to match '3 examples, 0 failures' }
end
