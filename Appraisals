current_ruby = Gem::Version.new(RUBY_VERSION)
ruby_2_7_0 = Gem::Version.new('2.7.0')
ruby_3_2_0 = Gem::Version.new('3.2.0')

rails_7_sqlite3 = '~> 1.4'
rails_8_sqlite3 = '>= 2.1'

ENV['OPAL_VERSION'] = nil # ensure the env is clean

github = -> repo_name { "https://github.com/#{repo_name}.git" }

{
  opal_1_8: -> gemfile do
    gemfile.gem 'opal', '~> 1.8.0'
  end,

}.each do |opal_version, gem_opal|
  appraise "rails_7_0_#{opal_version}" do
    gem "rails", "~> 7.0.0"
    gem 'sqlite3', rails_7_sqlite3
    gem_opal[self]
  end if current_ruby >= ruby_2_7_0

  appraise "rails_8_0_#{opal_version}" do
    gem "rails", "~> 8.0.0"
    gem 'sqlite3', rails_8_sqlite3
    gem_opal[self]
  end if current_ruby >= ruby_3_2_0

  appraise "rails_8_1_#{opal_version}" do
    gem "rails", "~> 8.1.0"
    gem 'sqlite3', rails_8_sqlite3
    gem_opal[self]
  end if current_ruby >= ruby_3_2_0
end
