describe 'Rake task' do
  subject { `rake opal:spec` }

  it { is_expected.to match '3 examples, 0 failures' }
end
