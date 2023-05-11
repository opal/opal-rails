require "haml"
require "haml/filters"
require "haml/filters/base"

module Haml
  class Filters
    class Opal < Base
      def mime_type
      end
      
      def compile(node)
        template = [:multi]
        template << [:static, "<script type='#{mime_type}'>\n"]
        template << [:static, ::Opal.compile(node.value[:text]) ]
        template << [:static, "\n</script>"]
        template
      end
    end
    ::Opal::Config.esm ? 'module' : 'text/javascript'
  end
end

Haml::Filters.registered[:opal] ||= Haml::Filters::Opal
