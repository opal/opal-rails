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
end

Opal::Rails::TaskHooks.apply!
