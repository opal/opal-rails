namespace :opal do
  desc 'Build configured Opal entrypoints into app/assets/builds'
  task build: :environment do
    app_config = Rails.application.config.opal

    resolver = Opal::Rails::EntrypointsResolver.new(
      entrypoints_path: app_config.entrypoints_path,
      entrypoints: app_config.entrypoints
    )
    entrypoints = resolver.resolve

    runner = Opal::Rails::BuilderRunner.new(config: app_config)
    result = runner.build(entrypoints: entrypoints)

    manifest = Opal::Rails::OutputsManifest.new(build_path: app_config.build_path)
    manifest.prune_stale!(result[:outputs])
    manifest.write!(result[:outputs])

    if result[:outputs].empty?
      puts 'Built 0 Opal assets'
    else
      puts "Built Opal assets: #{result[:outputs].join(', ')}"
    end
  end

  desc 'Remove Opal-owned build outputs from app/assets/builds'
  task clobber: :environment do
    manifest = Opal::Rails::OutputsManifest.new(build_path: Rails.application.config.opal.build_path)
    removed_outputs = manifest.clobber!

    if removed_outputs.nil?
      warn 'Skipped Opal clobber because the build manifest is unreadable'
    elsif removed_outputs.empty?
      puts 'Removed 0 Opal assets'
    else
      puts "Removed Opal assets: #{removed_outputs.join(', ')}"
    end
  end

  desc 'Watch configured Opal entrypoints and rebuild on change'
  task watch: :environment do
    require 'opal/rails/file_watcher'
    require 'opal/rails/watch_runner'
    Opal::Rails::WatchRunner.new(config: Rails.application.config.opal).watch
  end
end

Opal::Rails::TaskHooks.apply!
