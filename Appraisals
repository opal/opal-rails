current_ruby = Gem::Version.new(RUBY_VERSION)
ruby_2_2_2 = Gem::Version.new('2.2.2')
ruby_2_4_0 = Gem::Version.new('2.4.0')

appraise "rails-4-1" do
  gem "rails", "~> 4.1.16"
  gem "sprockets-rails", "< 3"
end if current_ruby < ruby_2_4_0

appraise "rails-4-2" do
  gem "rails", "~> 4.2.7"
end

appraise "rails-5" do
  gem "rails", "~> 5.0.0"
end if current_ruby >= ruby_2_2_2
