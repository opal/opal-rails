current_ruby = Gem::Version.new(RUBY_VERSION)
ruby_2_2_2 = Gem::Version.new('2.2.2')
ruby_2_4_0 = Gem::Version.new('2.4.0')

ENV['OPAL_VERSION'] = nil # ensure the env is clean

github = -> repo_name { "https://github.com/#{repo_name}.git" }

{
  opal_master: -> gemfile do
    gemfile.gem 'opal', git: github['opal/opal'], branch: :master
    gemfile.gem 'opal-rspec', git: github['opal/opal-rspec'], branch: :master
    gemfile.gem 'opal-sprockets', git: github['opal/opal-sprockets'], branch: :master
  end,
  opal_0_11: -> gemfile do
    gemfile.gem 'opal', '~> 0.11.0'
    gemfile.gem 'opal-rspec', git: github['opal/opal-rspec'], branch: :master
    gemfile.gem 'opal-sprockets'
  end,
}.each do |opal_version, gem_opal|
  appraise "rails-4-1-#{opal_version}" do
    gem "rails", "~> 4.1.16"
    gem "sprockets-rails", "< 3"
    gem_opal[self]
  end if current_ruby < ruby_2_4_0

  appraise "rails-4-2-#{opal_version}" do
    gem "rails", "~> 4.2.7"
    gem_opal[self]
  end

  appraise "rails-5-0-#{opal_version}" do
    gem "rails", "~> 5.0.0"
    gem_opal[self]
  end if current_ruby >= ruby_2_2_2

  appraise "rails-5-1-#{opal_version}" do
    gem "rails", "~> 5.1.0"
    gem_opal[self]
  end if current_ruby >= ruby_2_2_2

  appraise "rails-5-2-#{opal_version}" do
    gem "rails", "~> 5.2.0"
    gem_opal[self]
  end if current_ruby >= ruby_2_2_2
end
