source 'https://rubygems.org'
gemspec
github = -> repo { "https://github.com/#{repo}.git" }

if ENV['OPAL_VERSION'] == 'master'
  gem 'opal', git: github['opal/opal'], branch: :master
  gem 'opal-rspec', git: github['opal/opal-rspec'], branch: :master
  gem 'opal-sprockets', git: github['opal/opal-sprockets'], branch: :master
end
