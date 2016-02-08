module Opal
  module Rails
    module ControllerConfiguration

      def opal_renderer_config
        @opal_renderer_config ||= Struct.new(:auto_assign_instance_variables).new(true)
      end

      def configure_opal_renderer
        yield opal_renderer_config
      end

    end
  end
end

ActionController::Base.extend Opal::Rails::ControllerConfiguration
