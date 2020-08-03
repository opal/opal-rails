source 'https://rubygems.org'
gemspec
github = -> repo { "https://github.com/#{repo}.git" }

case ENV['OPAL_VERSION']
when 'local'
  gem 'opal', path: '../opal'
  gem 'opal-rspec', path: '../opal-rspec'
  gem 'opal-sprockets', path: '../opal-sprockets'
  gem 'pry'
when 'master'
  gem 'opal', git: github['opal/opal'], branch: :master
  gem 'opal-rspec', git: github['opal/opal-rspec'], branch: :master
  gem 'opal-sprockets', git: github['opal/opal-sprockets'], branch: :master
end

gem 'c_lexer'
