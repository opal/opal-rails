module OpalHelper
  def opal_tag(opal_code = nil, &block)
    opal_code ||= capture(&block)
    compiler_options = Opal::Processor.compiler_options.merge(requirable: false)
    compiler = Opal::Compiler.new(opal_code, compiler_options)
    js_code = compiler.compile
    javascript_tag js_code
  end

  def javascript_include_tag(*sources)
    sources_copy = sources.dup.tap(&:extract_options!)
    sprockets = Rails.application.assets

    script_tags = super

    sources_copy.map do |source|
      loading_code = Opal::Processor.load_asset_code(sprockets, source)
      script_tags << javascript_tag(loading_code) if loading_code.present?
    end
    script_tags
  end
end
