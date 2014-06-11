module Slim
  class Embedded
    class OpalEngine < TiltEngine
      protected

      def tilt_render(tilt_engine, tilt_options, text)
        [:static, ::Opal.compile(text)]
      end
    end
    register :opal, JavaScriptEngine, :engine => OpalEngine
  end
end if defined? Slim::Embedded
