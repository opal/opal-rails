require 'logger'
require 'rails'
ENV['RAILS_ENV'] = 'test'
ENV['DATABASE_URL'] = 'sqlite3::memory:'
require_relative '../../test_apps/rails'

module TestAppAssets
  module_function

  def build!
    config = Rails.application.config.opal
    resolved_entrypoints = Opal::Rails::EntrypointsResolver.new(
      entrypoints_path: config.entrypoints_path,
      entrypoints: config.entrypoints
    ).resolve

    result = Opal::Rails::BuilderRunner.new(config: config).build(entrypoints: resolved_entrypoints)
    manifest = Opal::Rails::OutputsManifest.new(build_path: config.build_path)
    manifest.prune_stale!(result[:outputs])
    manifest.write!(result[:outputs])
  end

  def clobber!
    Opal::Rails::OutputsManifest.new(build_path: Rails.application.config.opal.build_path).clobber!
  end
end
