source 'https://rubygems.org'
gemspec

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2')
  gem 'rails', '< 5'
end

if ENV['OPAL_VERSION'] == 'master'
  gem 'opal', github: 'opal', branch: :master
  gem 'opal-rspec', github: 'opal/opal-rspec', branch: 'elia/opal-master'
  gem 'opal-sprockets', github: 'opal/opal-sprockets', branch: :master
end
