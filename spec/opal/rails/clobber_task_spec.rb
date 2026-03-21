# frozen_string_literal: true

require 'rake'

RSpec.describe 'opal:clobber task' do
  let(:tasks_path) { File.expand_path('../../../../lib/tasks/opal.rake', __dir__) }

  before do
    Rake.application = Rake::Application.new
    Rails.application.load_tasks unless Rake::Task.task_defined?('opal:clobber')
    load tasks_path unless Rake::Task.task_defined?('opal:clobber')
  end

  after do
    Rake.application = nil
  end

  it 'removes only Opal-owned outputs and leaves unrelated files alone' do
    Dir.mktmpdir do |tmpdir|
      app_root = Pathname(tmpdir)
      build_path = app_root.join('app/assets/builds')
      FileUtils.mkdir_p(build_path)

      application_js = build_path.join('application.js')
      application_map = build_path.join('application.js.map')
      unrelated = build_path.join('application.css')
      keep_file = build_path.join('.keep')

      application_js.write('// opal output')
      application_map.write('{"version":3}')
      unrelated.write('body {}')
      keep_file.write('')

      manifest = Opal::Rails::OutputsManifest.new(build_path: build_path)
      manifest.write!(%w[application.js application.js.map])

      original_build_path = Rails.application.config.opal.build_path
      Rails.application.config.opal.build_path = build_path

      begin
        task = Rake::Task['opal:clobber']
        task.reenable
        task.invoke

        expect(application_js).not_to exist
        expect(application_map).not_to exist
        expect(build_path.join(Opal::Rails::OutputsManifest::FILE_NAME)).not_to exist
        expect(unrelated).to exist
        expect(keep_file).to exist
      ensure
        Rails.application.config.opal.build_path = original_build_path
      end
    end
  end
end
