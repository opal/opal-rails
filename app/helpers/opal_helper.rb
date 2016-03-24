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
    sprockets = Rails.application.assets
    skip_loader = options.delete(:skip_opal_loader)
    script_tags = super(*sources, options)

    return script_tags if skip_loader

    sources.each do |source|
      loading_code = Opal::Sprockets.load_asset(source, sprockets)
      script_tags << javascript_tag(loading_code) if loading_code.present?
    end

    script_tags
  end
end
