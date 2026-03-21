current_ruby = Gem::Version.new(RUBY_VERSION)
ruby_2_7_0 = Gem::Version.new('2.7.0')

ENV['OPAL_VERSION'] = nil # ensure the env is clean

github = -> repo_name { "https://github.com/#{repo_name}.git" }

{
  opal_1_7: -> gemfile do
    gemfile.gem 'opal', '~> 1.7.0'
  end,

  opal_1_3: -> gemfile do
    gemfile.gem 'opal', '~> 1.3.0'
  end,

  opal_1_0: -> gemfile do
    gemfile.gem 'opal', '~> 1.0.0'
  end,

}.each do |opal_version, gem_opal|
  appraise "rails_7_0_#{opal_version}" do
    gem "rails", "~> 7.0.0"
    gem_opal[self]
  end if current_ruby >= ruby_2_7_0
end
