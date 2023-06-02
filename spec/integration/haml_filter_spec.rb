RSpec.describe 'HAML filter', type: :feature, js: true do
  it 'works' do
    visit '/application/haml_filter'
    wait_for_dom_ready
    expect(page.evaluate_script('Opal.gvars.haml_filter')).to eq("working")
  end
end
