module OpalHelper
  def opal_tag(&block)
    opal_code = capture(&block)
    js_code = Opal.compile(opal_code)
    javascript_tag js_code
  end

end
