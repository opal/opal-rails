require 'spec_helper'
require 'rake'
require 'opal/rails/file_watcher'
require 'opal/rails/watch_runner'

RSpec.describe 'opal:watch task' do
  before do
    Rake.application = Rake::Application.new
    Rails.application.load_tasks
  end

  after do
    Rake.application = nil
  end

  it 'delegates to the watch runner' do
    runner = instance_double(Opal::Rails::WatchRunner, watch: true)
    expect(Opal::Rails::WatchRunner).to receive(:new).with(config: Rails.application.config.opal).at_least(:once).and_return(runner)

    Rake::Task['opal:watch'].reenable
    Rake::Task['opal:watch'].invoke
  end
end
