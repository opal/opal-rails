require 'spec_helper'
require 'support/capybara'

RSpec.describe 'The example app', type: :feature, js: true do
  it 'loads Opal' do
    visit '/'
    wait_for_dom_ready
    expect(page.evaluate_script('window.opal_loaded === true')).to eq(true)
  end
end
