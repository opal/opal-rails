source 'https://rubygems.org'
gemspec
github = -> repo { "https://github.com/#{repo}.git" }

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2')
  gem 'rails', '< 5'
end

if ENV['OPAL_VERSION'] == 'master'
  gem 'opal', git: github['opal/opal'], branch: :master
  gem 'opal-rspec', git: github['opal/opal-rspec'], branch: :master
  gem 'opal-sprockets', git: github['opal/opal-sprockets'], branch: :master
end

# NOTE:
#
# building capybara-webkit with homebrew:
#
#   brew install qt@5.5
#   export PATH=(brew --prefix qt@5.5)/bin:"$PATH"
#   bundle install
#
