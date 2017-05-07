# coding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'opal/rails/version'

Gem::Specification.new do |s|
  s.name        = 'opal-rails'
  s.version     = Opal::Rails::VERSION
  s.authors     = ['Elia Schito']
  s.email       = ['elia@schito.me']
  s.homepage    = 'https://github.com/opal/opal-rails#readme'
  s.summary     = %q{Rails bindings for opal JS engine}
  s.description = %q{Rails bindings for opal JS engine}
  s.license     = 'MIT-LICENSE'
  s.post_install_message = [
   "BEWARE: Spec support is being extracted from `opal-rails` into `opal-rspec-rails`",
   "        Please use `opal-rspec-rails` or the 0-8-stable branch."
  ].join("\n")

  s.rubyforge_project = 'opal-rails'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  required_ruby_version = '>= 2.1'

  s.add_dependency 'rails',               '>= 4.1', '< 6.0'
  s.add_dependency 'sprockets-rails',     '>= 2.3.3', '< 4.0'
  s.add_dependency 'jquery-rails'

  s.add_dependency 'opal',                '>= 0.8.0', '< 0.11'
  s.add_dependency 'opal-jquery',         '~> 0.4.0'
  s.add_dependency 'opal-sprockets',      '~> 0.4.1'
  s.add_dependency 'opal-activesupport',  '>= 0.0.5'

  s.add_development_dependency 'execjs'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'capybara', '~> 2.3'
  s.add_development_dependency 'poltergeist', '~> 1.15.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'appraisal', '~> 2.1'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'capybara-webkit'
  s.add_development_dependency 'puma'
end
