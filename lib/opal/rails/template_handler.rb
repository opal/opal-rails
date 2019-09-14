module Opal
  module Rails
    class TemplateHandler

      def self.call(template, source = template.source)
        new.call(template, source)
      end

      def call(template, source = template.source)
        escaped = source.gsub(':', '\:')
        string = '%q:' + escaped + ':'

        <<-RUBY
          config = ::Rails.application.config.opal

          code = []
          code << 'Object.new.instance_eval {'

          if config.assign_locals_in_templates?
            code << JSON.parse(local_assigns.to_json).map { |key, val| "\#{key} = \#{val.inspect};" }.join
          end

          if config.assign_instance_variables_in_templates?
            code << JSON.parse(@_assigns.to_json).map { |key, val| "@\#{key} = \#{val.inspect};" }.join
          end

          code << #{string}
          code << '}'
          Opal.compile(code.join("\n"))
        RUBY
      end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Template.register_template_handler :opal, Opal::Rails::TemplateHandler
end
