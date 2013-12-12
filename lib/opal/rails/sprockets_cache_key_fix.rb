require 'sprockets/base'
require 'opal/version'
require 'opal/sprockets/processor'

def (Opal::Processor).version
  Opal::VERSION
end unless Opal::Processor.respond_to? :version

class Sprockets::Base
  def cache_key_for(path, options)
    processors = attributes_for(path).processors
    processors_key = processors.map do |p|
      version = p.respond_to?(:version) ? p.version : '0'
      "#{p.name}-#{version}"
    end.join(':')

    "#{path}:#{options[:bundle] ? '1' : '0'}:#{processors_key}"
  end
end
