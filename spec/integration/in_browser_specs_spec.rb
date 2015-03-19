require 'spec_helper'

feature 'In-browser specs runner' do
  scenario 'runs all specs', :js do
    visit '/opal_spec'
    page.should have_content('example_spec ')
    page.should have_content('requires_opal_spec ')
    page.should have_content('subdirectory/other_spec ')
    page.should have_content('3 examples, 0 failures')
  end

  scenario "runs single spec file", :js do
    visit '/opal_spec'
    click_link 'subdirectory/other_spec'

    page.should_not have_content('example_spec ')
    page.should_not have_content('requires_opal_spec ')
    page.should have_content('subdirectory/other_spec ')
    page.should have_content('1 examples, 0 failures')
  end
end
