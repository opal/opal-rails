require 'spec_helper'

describe 'In-browser specs runner', js: true, type: :feature do
  before do
    visit '/opal_spec'
  end
  
  it 'all specs' do
    expect(page).to have_content('3 examples, 0 failures')
    expect(page).to have_content('example_spec ')
    expect(page).to have_content('requires_opal_spec ')
    expect(page).to have_content('subdirectory/other_spec ')  
  end
  
  it 'single spec file' do
    click_link 'subdirectory/other_spec'
    
    expect(page).to have_content('1 examples, 0 failures')
    expect(page).to_not have_content('example_spec ')
    expect(page).to_not have_content('requires_opal_spec ')
    expect(page).to have_content('subdirectory/other_spec ')
    expect(page).to have_link 'All specs'
  end
end

