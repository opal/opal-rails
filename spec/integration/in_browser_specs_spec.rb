require 'spec_helper'

feature 'In-browser specs runner' do
  before { skip 'STILL NEED TO FIX FOR OPAL-RSPEC' }

  scenario 'runs all specs', :js do
    visit '/opal_spec'

    page.should have_content('subdirectory/other_spec.js')
    page.should have_content('example_spec.js ')
    page.should have_content('2 examples, 0 failures')
  end

  scenario "runs single spec file", :js do
    visit '/opal_spec'
    click_link 'subdirectory/other_spec.js'

    page.should have_content('Running: subdirectory/other_spec.js')
    page.should have_content('1 examples, 0 failures')
  end
end
