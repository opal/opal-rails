require 'spec_helper'

describe Opal::Processor do
  let(:pathname) { Pathname('/Code/app/mylib/opal/asdf.rb') }
  let(:_context) do
    double('_context', :logical_path => 'asdf.js.rb', :pathname => pathname)
  end

  it "is registered for '.opal' files" do
    Tilt['test.opal'].should eq(Opal::Processor)
  end

  it "is registered for '.rb' files" do
    Tilt['test.rb'].should eq(Opal::Processor)
  end

  it "compiles and evaluates the template on #render" do
    template = Opal::Processor.new { |t| "puts 'Hello, World!'\n" }
    template.render(_context).should include('"Hello, World!"')
  end

  it "can be rendered more than once" do
    template = Opal::Processor.new(_context) { |t| "puts 'Hello, World!'\n" }
    3.times { template.render(_context).should include('"Hello, World!"') }
  end
end
