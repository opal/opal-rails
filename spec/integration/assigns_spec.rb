require 'spec_helper'
require 'execjs'

describe 'controller assignments' do
  context 'by default' do
    before do
      expect(::Rails.application.config.opal.assigns_in_templates).to eq(true)
    end

    it 'are in the template' do
      source = get_source_of '/application/with_assignments.js'
      source.gsub!(/;\s*\Z/,'') # execjs eval doesn't like the trailing semicolon
      assignments = opal_eval(source)

      {
        :number_var => 1234,
        :string_var => 'hello',
        :array_var  => [1,'a'],
        :hash_var   => {:a => 1, :b => 2}.stringify_keys,
        :object_var => {:contents => 'json representation'}.stringify_keys,
        :local_var  => 'i am local',
      }.each_pair do |ivar, assignment|
        assignments[ivar.to_s].should eq(assignment)
      end
    end
  end

  context 'when disabled' do
    before do
      Rails.application.config.opal.assigns_in_templates = false
    end

    it 'are not in the template' do

      source = get_source_of '/application/with_assignments.js'
      source.gsub!(/;\s*\Z/,'') # execjs eval doesn't like the trailing semicolon
      assignments = opal_eval(source)

      {
        :number_var => 1234,
        :string_var => 'hello',
        :array_var  => [1,'a'],
        :hash_var   => {:a => 1, :b => 2}.stringify_keys,
        :object_var => {:contents => 'json representation'}.stringify_keys,
        :local_var  => 'i am local',
      }.each_pair do |ivar, assignment|
        assignments[ivar.to_s].should_not eq(assignment)
      end
    end
  end

  def get_source_of path
    get path
    response.should be_success
    source = response.body
  end

  def opal_eval source
    builder = Opal::Builder.new
    builder.build 'opal'

    # Any lib should be already required in the page,
    # require won't work in this kind of templates.
    builder.build 'native'

    context = ExecJS.compile builder.to_s
    context.eval source
  rescue
    $!.message << "\n\n#{source}"
    raise
  end
end
