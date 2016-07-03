require 'rails/generators/named_base'

module Opal
  module Generators
    class AssetsGenerator < ::Rails::Generators::NamedBase
      source_root __dir__+'/templates'
      def copy_opal
        template 'javascript.js.rb', File.join('app/assets/javascripts', class_path, "#{file_name}.js.rb")
      end
    end
  end
end
