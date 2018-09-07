require 'spec_helper'

describe 'template handler' do
  it 'has the correct content type' do
    get '/application/with_assignments.js'
    expect(response).to be_successful
    expect(response.headers['Content-Type']).to eq('text/javascript; charset=utf-8')
  end
end
