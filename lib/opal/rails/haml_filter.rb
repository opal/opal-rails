require 'opal'
require 'haml'

raise LoadError, 'opal-rails requires Haml 6 or newer for the :opal filter' if Haml::VERSION.to_i < 6

require 'opal/rails/haml6_filter'
