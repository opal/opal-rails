require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'

module Opal
  module Generators
    class AssetsGenerator < ::Rails::Generators::NamedBase
      include ::Rails::Generators::ResourceHelpers
      source_root __dir__+'/templates'

      def initialize(*args)
    
        module_name = ::Rails::Generators.const_defined?('ModelHelpers') ? 'ModelHelpers' : 'ResourceHelpers'
        ::Rails::Generators.const_get(module_name).skip_warn = true
        super
      end

      def copy_opal
        template 'javascript.js.rb', File.join('app/assets/javascripts', class_path, "#{controller_name}_view.js.rb")
      end
    end
  end
end
