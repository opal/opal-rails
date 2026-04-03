require 'spec_helper'
require 'rake'

RSpec.describe Opal::Rails::TaskHooks do
  let(:rake_application) { Rake::Application.new }

  before do
    Rake.application = rake_application
    rake_application.define_task(Rake::Task, 'opal:build')
    rake_application.define_task(Rake::Task, 'opal:clobber')
  end

  after do
    Rake.application = nil
  end

  it 'attaches opal:build to known hook tasks when they exist' do
    rake_application.define_task(Rake::Task, 'assets:precompile')
    rake_application.define_task(Rake::Task, 'test:prepare')

    described_class.apply!(task_manager: Rake::Task)

    expect(Rake::Task['assets:precompile'].prerequisites).to include('opal:build')
    expect(Rake::Task['test:prepare'].prerequisites).to include('opal:build')
  end

  it 'does not duplicate prerequisites when applied more than once' do
    rake_application.define_task(Rake::Task, 'assets:precompile')

    2.times { described_class.apply!(task_manager: Rake::Task) }

    expect(Rake::Task['assets:precompile'].prerequisites.count('opal:build')).to eq(1)
  end

  it 'allows later task definitions to be hooked by reapplying' do
    described_class.apply!(task_manager: Rake::Task)
    rake_application.define_task(Rake::Task, 'spec:prepare')

    described_class.apply!(task_manager: Rake::Task)

    expect(Rake::Task['spec:prepare'].prerequisites).to include('opal:build')
  end

  it 'attaches opal:clobber to assets:clobber when it exists' do
    rake_application.define_task(Rake::Task, 'assets:clobber')

    described_class.apply!(task_manager: Rake::Task)

    expect(Rake::Task['assets:clobber'].prerequisites).to include('opal:clobber')
  end

  it 'attaches test:prepare to the test task so rake test triggers opal:build' do
    rake_application.define_task(Rake::Task, 'test')
    rake_application.define_task(Rake::Task, 'test:prepare')

    described_class.apply!(task_manager: Rake::Task)

    expect(Rake::Task['test'].prerequisites).to include('test:prepare')
    expect(Rake::Task['test:prepare'].prerequisites).to include('opal:build')
  end
end
