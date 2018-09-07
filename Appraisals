current_ruby = Gem::Version.new(RUBY_VERSION)
ruby_2_2_2 = Gem::Version.new('2.2.2')
ruby_2_4_0 = Gem::Version.new('2.4.0')

ENV['OPAL_VERSION'] = nil # ensure the env is clean

{
  opal_master: -> gemfile do
    gemfile.gem 'opal', github: 'opal', branch: :master
    gemfile.gem 'opal-rspec', github: 'opal/opal-rspec', branch: :master
    gemfile.gem 'opal-sprockets', github: 'opal/opal-sprockets', branch: :master
  end,
  opal_0_10: -> gemfile do
    gemfile.gem 'opal', '~> 0.10.5'
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
end
