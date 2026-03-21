class Opal::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def create_opal_files
    create_application_entrypoint
    template 'initializer.rb.tt', 'config/initializers/opal.rb'
    empty_directory 'app/assets/builds'
    create_file 'app/assets/builds/.keep' unless destination_file_exist?('app/assets/builds/.keep')
    ensure_manifest_build_links
    ensure_test_asset_debug
    ensure_gitignore_entries
    ensure_procfile_dev
    ensure_bin_dev
    ensure_javascript_include_tag
  end

  private

  def create_application_entrypoint
    return unless generate_application_entrypoint?

    template 'application.rb', application_entrypoint_path
  end

  def opal_source_path
    destination_directory_exist?('app/assets/opal') ? 'app/assets/opal' : 'app/opal'
  end

  def application_entrypoint_path
    File.join(opal_source_path, 'application.rb')
  end

  def generate_application_entrypoint?
    return false if destination_file_exist?(application_entrypoint_path)

    existing_top_level_entrypoints.empty?
  end

  def application_entrypoint_available?
    generate_application_entrypoint? || destination_file_exist?(application_entrypoint_path)
  end

  def entrypoints_literal
    return ':all' if bulk_entrypoints_layout?

    "{ '#{application_logical_name}' => 'application.rb' }"
  end

  def application_logical_name
    application_asset_name_reserved? ? 'opal' : 'application'
  end

  def application_asset_name_reserved?
    reserved_application_asset_paths.any? { |path| destination_file_exist?(path) }
  end

  def reserved_application_asset_paths
    %w[
      app/javascript/application.js
      app/javascript/application.mjs
      app/javascript/application.ts
      app/javascript/application.tsx
      app/assets/javascripts/application.js
      app/assets/javascripts/application.js.erb
      app/assets/builds/application.js
    ]
  end

  def bulk_entrypoints_layout?
    return false if existing_top_level_entrypoints.empty?

    existing_top_level_entrypoints.length > 1 || existing_top_level_entrypoints.first != 'application.rb'
  end

  def existing_top_level_entrypoints
    @existing_top_level_entrypoints ||= begin
      source_root_path = destination_path(opal_source_path)
      if File.directory?(source_root_path)
        Dir.children(source_root_path)
           .select { |entry| entry.end_with?('.rb') && File.file?(File.join(source_root_path, entry)) }
           .sort
      else
        []
      end
    end
  end

  def ensure_gitignore_entries
    return unless destination_file_exist?('.gitignore')

    append_unless_present('.gitignore', "/app/assets/builds/*\n")
    append_unless_present('.gitignore', "!/app/assets/builds/.keep\n")
  end

  def ensure_manifest_build_links
    manifest_path = 'app/assets/config/manifest.js'
    return unless destination_file_exist?(manifest_path)

    append_unless_present(manifest_path, "//= link_directory ../builds .js\n")
    append_unless_present(manifest_path, "//= link_directory ../builds .map\n")
  end

  def ensure_test_asset_debug
    test_env_path = 'config/environments/test.rb'
    return unless destination_file_exist?(test_env_path)
    return unless destination_file_exist?('app/assets/config/manifest.js')

    test_env_contents = File.read(destination_path(test_env_path))
    return if test_env_contents.match?(/config\.assets\.debug\s*=/)

    insert_into_file test_env_path, "\n  config.assets.debug = true", before: /\nend\s*\z/
  end

  def ensure_procfile_dev
    if destination_file_exist?('Procfile.dev')
      append_unless_present('Procfile.dev', "opal: bin/rails opal:watch\n")
    else
      create_file 'Procfile.dev', "web: bin/rails server\nopal: bin/rails opal:watch\n"
    end
  end

  def ensure_bin_dev
    if destination_file_exist?('bin/dev')
      # Replace bin/dev if it doesn't use Procfile.dev -- Rails 8.1+
      # generates a bin/dev that just execs "bin/rails server" directly.
      bin_dev_content = File.read(destination_path('bin/dev'))
      return if bin_dev_content.include?('Procfile.dev')

      remove_file 'bin/dev'
    end

    empty_directory 'bin'
    template 'dev', 'bin/dev'
    chmod 'bin/dev', 0o755
  end

  def ensure_javascript_include_tag
    layout_path = 'app/views/layouts/application.html.erb'
    return unless destination_file_exist?(layout_path)
    return unless application_entrypoint_available?

    layout_contents = File.read(destination_path(layout_path))
    return if layout_contents.match?(/javascript_include_tag\s+["']#{Regexp.escape(application_logical_name)}["']/)

    tag = %(<%= javascript_include_tag "#{application_logical_name}", "data-turbo-track": "reload" %>)

    insert_into_file layout_path, "  #{tag}\n", before: %r{\n *</head>}
  end

  def append_unless_present(path, contents)
    append_to_file(path, contents) unless File.read(destination_path(path)).include?(contents.strip)
  end

  def destination_directory_exist?(relative_path)
    File.directory?(destination_path(relative_path))
  end

  def destination_file_exist?(relative_path)
    File.exist?(destination_path(relative_path))
  end

  def destination_path(relative_path)
    File.join(destination_root, relative_path)
  end
end
