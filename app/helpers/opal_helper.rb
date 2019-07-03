require 'opal/sprockets'

module OpalHelper
  def opal_tag(opal_code = nil, &block)
    opal_code ||= capture(&block)
    compiler_options = Opal::Config.compiler_options.merge(requirable: false)
    compiler = Opal::Compiler.new(opal_code, compiler_options)
    js_code = compiler.compile
    javascript_tag js_code
  end

  def javascript_include_tag(*sources)
    options = sources.extract_options!
    skip_loader = options.delete(:skip_opal_loader)
    skip_onload = options.delete(:force_opal_loader_tag)
    debug = options["debug"] != false && request_debug_assets? # taken from spro

    return super(*sources, options) if skip_loader

    script_tags = "".html_safe
    sources.each do |source|
      load_asset_code = Opal::Sprockets.load_asset(source)
      loading_code = "if(Opal.modules[#{source.to_json}]){#{load_asset_code}}"

      if skip_onload
        script_tags << super(source, options)
        script_tags << javascript_tag(loading_code)
      else
        script_tags << super(source, options.merge(onload: loading_code))
      end
    end
    script_tags
  end
end
