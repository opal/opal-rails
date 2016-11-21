RSpec.configure do |config|
  config.before(:each) {
    Rails.application.config.opal.assigns_in_templates = true
  }
end
