source 'https://rubygems.org'
gemspec
github = -> repo { "https://github.com/#{repo}.git" }

case ENV['OPAL_VERSION']
when 'local'
  gem 'opal', path: '../opal'
  gem 'opal-rspec', path: '../opal-rspec'
  gem 'pry'
when 'master'
  gem 'opal', git: github['opal/opal'], branch: :master
end

gem 'net-smtp'

gem "gem-release", "~> 2.2"
