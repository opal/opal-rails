# Check out the full list of the available configuration options at
# https://github.com/opal/opal/blob/master/lib/opal/config.rb

Rails.application.configure do
  # We suggest keeping the configuration above as default for all environments,
  # disabling some of them might slightly reduce the bundle size or reduce performance
  # by degrading some ruby features.
  config.opal.method_missing_enabled   = true
  config.opal.const_missing_enabled    = true
  config.opal.arity_check_enabled      = true
  config.opal.freezing_stubs_enabled   = true
  config.opal.dynamic_require_severity = :ignore

  # To enable passing assigns from the controller to the opal template handler
  # change the following configuration to one of these values:
  #
  #   - true    # both locals and instance variables
  #   - :locals # only locals
  #   - :ivars  # only instance variables
  #
  config.opal.assigns_in_templates = false
end
