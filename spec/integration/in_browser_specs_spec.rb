require 'spec_helper'

describe 'In-browser specs runner' do
  it 'runs all specs', :js do
    visit '/opal_spec'
    page.should have_content(' subdirectory/other_spec.js ')
    page.should have_content(' example_spec.js ')
    page.should have_content('2 examples, 0 failures')
  end

  it "runs single spec file", :js do
    visit '/opal_spec'
    click_link 'subdirectory/other_spec.js'
    page.should have_content('Running: subdirectory/other_spec.js')
    page.should have_content('1 examples, 0 failures')
  end
end
