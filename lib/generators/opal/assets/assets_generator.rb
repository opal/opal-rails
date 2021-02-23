class Opal::AssetsGenerator < ::Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def copy_opal
    template 'javascript.js.rb', File.join('app/assets/javascripts', class_path, "#{file_name}.js.rb")
  end
end
