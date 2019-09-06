current_ruby = Gem::Version.new(RUBY_VERSION)
ruby_2_4_0 = Gem::Version.new('2.4.0')
ruby_2_5_0 = Gem::Version.new('2.5.0')

ENV['OPAL_VERSION'] = nil # ensure the env is clean

github = -> repo_name { "https://github.com/#{repo_name}.git" }

{

  opal_master: -> gemfile do
    gemfile.gem 'opal', git: github['opal/opal'], branch: :master
    gemfile.gem 'opal-rspec', git: github['opal/opal-rspec'], branch: :master
    gemfile.gem 'opal-sprockets', git: github['opal/opal-sprockets'], branch: :master
  end,

  opal_1_0: -> gemfile do
    gemfile.gem 'opal', '~> 1.0.0'
    gemfile.gem 'opal-rspec', git: github['opal/opal-rspec'], branch: :master
    gemfile.gem 'opal-jquery', git: github['opal/opal-jquery'], branch: :master
    gemfile.gem 'opal-sprockets'
  end,

}.each do |opal_version, gem_opal|
  appraise "rails_5_1_#{opal_version}" do
    gem "rails", "~> 5.1.0"
    gem_opal[self]
  end if current_ruby >= ruby_2_4_0

  appraise "rails_5_2_#{opal_version}" do
    gem "rails", "~> 5.2.0"
    gem_opal[self]
  end if current_ruby >= ruby_2_4_0

  appraise "rails_6_0_#{opal_version}" do
    gem "rails", "~> 6.0.0"
    gem_opal[self]
  end if current_ruby >= ruby_2_5_0
end
