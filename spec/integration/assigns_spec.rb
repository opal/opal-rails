require 'spec_helper'
require 'execjs'

describe 'controller assignments' do
  context 'when enabled' do
    before do
      Rails.application.config.opal.assigns_in_templates = true
    end

    it 'are in the template' do
      source = get_source_of '/application/with_assignments.js'
      assignments = opal_eval(source)

      {
        :number_var => 1234,
        :string_var => 'hello',
        :array_var  => [1,'a'],
        :hash_var   => {:a => 1, :b => 2},
        :object_var => {:contents => 'json representation'},
        :local_var  => 'i am local',
      }.each_pair do |ivar, assignment|
        expect(assignments[ivar]).to eq(assignment)
      end
    end
  end

  context 'when disabled' do
    before do
      Rails.application.config.opal.assigns_in_templates = false
    end

    it 'are not in the template' do
      source = get_source_of '/application/with_assignments.js'
      assignments = opal_eval(source)
      {
        :number_var => 1234,
        :string_var => 'hello',
        :array_var  => [1,'a'],
        :hash_var   => {:a => 1, :b => 2},
        :object_var => {:contents => 'json representation'},
        :local_var  => 'i am local',
      }.each_pair do |ivar, assignment|
        expect(assignments[ivar]).not_to eq(assignment)
      end
    end
  end

  def get_source_of path
    get path
    response.should be_successful
    source = response.body
  end

  def opal_eval source
    source = source.gsub(/;\s*\Z/,'') # execjs eval doesn't like the trailing semicolon
    builder = Opal::Builder.new
    builder.build 'opal'

    # Any lib should be already required in the page,
    # require won't work in this kind of templates.
    builder.build 'json'

    context = ExecJS.compile builder.to_s
    JSON.parse context.eval(source), symbolize_names: true
  rescue
    $!.message << "\n\n#{source}"
    raise
  end
end
