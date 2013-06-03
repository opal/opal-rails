require 'opal'

class << Opal
  attr_writer :default_options
  def default_options
    @default_options ||= {}
  end

  def parse_with_default_options source, options = {}
    parse_without_default_options(source, default_options.merge(options))
  end

  alias parse_without_default_options parse
  alias parse parse_with_default_options
end



