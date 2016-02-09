module Opal
  module Rails
    class Configuration < SimpleDelegator

      def initialize
        super(ActiveSupport::OrderedOptions.new)
      end

      def configure_processor
        each_pair do |key, value|
          key = "#{key}="
          Opal::Processor.send(key, value) if Opal::Processor.respond_to? key
        end
      end

      def auto_assign_instance_variables?(action_params)
        case ivar_config = auto_assign_instance_variables
        when true, false
          ivar_config
        when Hash
          if included_controllers = ivar_config[:only]
            return false unless test_inclusion included_controllers, action_params
          end
          if excluded_controllers = ivar_config[:except]
            return false unless test_exclusion excluded_controllers, action_params
          end
          true
        else
          true
        end
      end

      private

      def test_inclusion matchers, target
        normalize_action_matcher(matchers).any? do |matcher|
          match_action_params matcher, target
        end
      end

      def test_exclusion matchers, action_params
        ! test_inclusion matchers, action_params
      end

      def normalize_action_matcher matchers
        Array(matchers).map{|it| Hash[[:controller, :action].zip(it.split('#'))] }
      end

      def match_action_params matcher, target
        return false if matcher[:controller] && matcher[:controller] != target[:controller]
        return false if matcher[:action] && matcher[:action] != target[:action]
        ! [matcher, target].any? {|it| it[:controller].blank? && it[:action].blank? }
      end

      def __setobj__(*args)
        super
      end

    end
  end
end
