module Opal
  module Rails
    class TemplateHandler

      def self.call(template)
        new.call(template)
      end

      def call(template)
        escaped = template.source.gsub(':', '\:')
        string = '%q:' + escaped + ':'

        "Opal.compile('Object.new.instance_eval {' << #{assigns} << #{local_assigns} << #{string} << '}')"
      end

      private

      def local_assigns
        <<-'RUBY'.strip
          JSON.parse(local_assigns.to_json).map { |key, val| "#{key} = #{val.inspect};" }.join
        RUBY
      end

      def assigns
        <<-'RUBY'.strip
          if ! controller.respond_to?(:assign_opal_instance_variables?) || controller.assign_opal_instance_variables?
            JSON.parse(@_assigns.to_json).map { |key, val| "@#{key} = #{val.inspect};" }.join
          else
            ''
          end
        RUBY
      end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Template.register_template_handler :opal, Opal::Rails::TemplateHandler
end
