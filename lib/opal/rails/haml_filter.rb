require 'haml'

haml_version = Haml::VERSION.to_i

if haml_version < 6
  require 'opal/rails/haml5_filter'
else
  require 'opal/rails/haml6_filter'
end
