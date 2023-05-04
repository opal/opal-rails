require "haml"
require "haml/filters"
require "haml/filters/base"

module Haml
  class Filters
    class Opal < Base
      def compile(node)
        template = [:multi]
        template << [:static, "<script type='text/javascript'>\n"]
        template << [:static, ::Opal.compile(node.value[:text]) ]
        template << [:static, "\n</script>"]
        template
      end
    end
  end
end

Haml::Filters.registered[:opal] ||= Haml::Filters::Opal
