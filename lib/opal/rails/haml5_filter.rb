module Haml::Filters::Opal
  include Haml::Filters::Base

  def mime_type
    ::Opal::Config.esm ? 'module' : 'text/javascript'
  end

  def render_with_options ruby, options
    text = ::Opal.compile(ruby)

    if options[:format] == :html5
      type = ''
    else
      type = " type=#{options[:attr_wrapper]}#{mime_type}#{options[:attr_wrapper]}"
    end

    text.rstrip!
    text.gsub!("\n", "\n    ")

    <<HTML
<script#{type}>
  //<![CDATA[
    #{text}
  //]]>
</script>
HTML
  end
end
