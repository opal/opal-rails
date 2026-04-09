module OpalHelper
  def opal_tag(opal_code_or_options = nil, html_options = {}, &block)
    if block_given?
      html_options = opal_code_or_options if opal_code_or_options.is_a?(Hash)
      opal_code_or_options = capture(&block)
    end

    compiler_options = Opal::Config.compiler_options.merge(requirable: false)
    compiler = Opal::Compiler.new(opal_code_or_options, compiler_options)
    js_code = compiler.compile
    javascript_tag html_options do
      js_code.html_safe
    end
  end
end
