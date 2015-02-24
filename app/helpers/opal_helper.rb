module OpalHelper
  def opal_tag(&block)
    opal_code = capture(&block)
    js_code = Opal.compile(opal_code)
    javascript_tag js_code
  end

  def spec_include_tag(*sources)
    options = sources.extract_options!.stringify_keys
    path_options = options.extract!('protocol', 'extname').symbolize_keys
    sources.uniq.map { |source|
      tag_options = {
        "src" => "/opal_spec_files/#{source}"
      }.merge!(options)
      content_tag(:script, "", tag_options)
    }.join("\n").html_safe
  end
end
