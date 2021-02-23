class Opal::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def configure_sprockets
    append_to_file 'app/assets/config/manifest.js', '//= link_directory ../javascript .js'
    template "application.js.rb", "app/assets/javascript/application.js.rb"

    # Add the javascript tag to the application head tag
    gsub_file 'app/views/layouts/application.html.erb', %r{^( *)</head>},
      '\1  <%= javascript_include_tag "application", "data-turbolinks-track": "reload" %>\1</head>'
  end
end
