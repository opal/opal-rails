# frozen_string_literal: true

require_relative 'lib/opal/rails/version'

Gem::Specification.new do |spec|
  spec.name        = 'opal-rails'
  spec.version     = Opal::Rails::VERSION
  spec.authors     = ['Elia Schito']
  spec.email       = ['elia@schito.me']

  spec.summary     = %q{Rails bindings for opal JS engine}
  spec.description = %q{Rails bindings for opal JS engine}
  spec.homepage    = 'https://github.com/opal/opal-rails#readme'
  spec.license     = 'MIT-LICENSE'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/opal/opal-rails#readme'
  spec.metadata['changelog_uri'] = 'https://github.com/opal/opal-rails/blob/master/CHANGELOG.md'

  spec.required_ruby_version = Gem::Requirement.new('~> 2.3')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails',               '>= 5.1', '< 6.1'
  spec.add_dependency 'sprockets-rails',     '~> 2.3.1'
  spec.add_dependency 'jquery-rails'

  spec.add_dependency 'opal',                '~> 1.0.0'
  spec.add_dependency 'opal-jquery',         '~> 0.4.4'
  spec.add_dependency 'opal-sprockets',      '~> 0.5.0'
  spec.add_dependency 'opal-activesupport',  '>= 0.0.5'

  spec.add_development_dependency 'execjs'
  spec.add_development_dependency 'launchy'
  spec.add_development_dependency 'capybara', '~> 3.25'
  spec.add_development_dependency 'apparition'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'appraisal', '~> 2.1'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'puma'
end
