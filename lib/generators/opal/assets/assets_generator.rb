class Opal::AssetsGenerator < ::Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def copy_opal
    template 'asset.rb.tt', File.join(opal_source_path, class_path, "#{file_name}.rb")
  end

  private

  def opal_source_path
    destination_directory_exist?('app/assets/opal') ? 'app/assets/opal' : 'app/opal'
  end

  def destination_directory_exist?(relative_path)
    File.directory?(File.join(destination_root, relative_path))
  end
end
