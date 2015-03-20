module OpalHelper
  def opal_tag(&block)
    opal_code = capture(&block)
    js_code = Opal.compile(opal_code)
    javascript_tag js_code
  end

  def javascript_include_tag(*sources)
    sources_copy = sources.dup.tap(&:extract_options!)
    sprockets = Rails.application.assets

    script_tags = super

    sources_copy.map do |source|
      loading_code = Opal::Processor.load_asset_code(sprockets, source)
      script_tags << javascript_tag(loading_code)
    end
    script_tags
  end
end
