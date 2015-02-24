# needs to be full pathname instead of relative pathname to run in the opal-rails spec
Rails.application.config.opal.spec_location = "#{Rails.root}/app/assets/javascripts/spec"
