# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

Changes are grouped as follows:
- **Added** for new features.
- **Changed** for changes in existing functionality.
- **Deprecated** for once-stable features removed in upcoming releases.
- **Removed** for deprecated features removed in this release.
- **Fixed** for any bug fixes.
- **Security** to invite users to upgrade in case of vulnerabilities.

<!--
Whitespace conventions:
- 4 spaces before ## titles
- 2 spaces before ### titles
- 2 spaces before ### titles
- 1 spaces before normal text
 -->




## [0.9.0] - Unreleased


### Added

- Support for Opal 0.9
- Support for Rails 5.0


### Removed

- Removed support for Opal 0.8
- Extracted support for running spec to `opal-rspec-rails`, this is done to make its development independent of `opal-rails` and also to make room for the (yet to be implemented) `opal-minitest-rails`. In addition the extracted gem should address a number of issues like:
  - faster rake runs
  - allowing to use any sprockets processor (e.g. `opal-haml` templates were previously not supported)
  - nicer integration and customizability




## [0.8.1] - 2015-12-18

- Restrict the version requirement for `sprockets-rails` to `< 3.0` as v3 bears chages incompatible with `opal-rails`


## [0.8.0] - 2015-07-20

- Opal v0.8
- Default spec location is now `spec-opal`, this will allow opal specs to be "alphabetically" near other specs.
- Don't run the sourcemap server unless sprockets is active and sourcemaps enabled and sprockets is in debug mode
- Align spec compilation done via `rake opal:spec` vs. in the browser at `/opal_spec`
- Dynamic require severity now defaults to `:ignore`
- Make `#opal_tag` helper respect provided options + specs
- Sprockets bootstrap code can be skipped from `javascript_include_tag` passing `skip_opal_loader: true`
- All specs now need to `require "opal"` and `require "opal-rspec"` explicitly


## [0.7.0] - 2015-02-02

- Opal v0.7
- Added an `opal` Slim filter
- WebScale!
- Drop Ruby 1.8.7 support
- Add a view rails generator `rails g opal:assets` to generate example view classes.


## [0.6.3] - 2014-03-07

- Add `opal_tag` helper, similar to `javascript_tag`
- Allow specs inside subdirectories
- Updated to Opal v0.6


## [0.6.2] - 2013-12-13

- Added fun
- Expire Sprockets cache (by means of using different cache keys) when the opal version changes (monkeypatch)
- Rely on `Opal::Processor` to know if source maps are enabled


## [0.6.1] - 2013-11-05

- Fix the rake task, now uses `opal-rspec` too


## [0.6.0] - 2013-11-05

- Don't load source maps if they're not enabled via `config.opal.source_map_enabled`
- Update to Opal v0.5.0
- Run in-browser specs with `opal-rspec`


## [0.5.2] - 2013-09-05

- Add `opal-activesupport` as a dependency
- Haml filter now is loaded inside the railtie initializer, avoiding potential Gemfile ordering issues
- Add the `rake opal:spec` task to run browser specs from the terminal (requires phantomjs)


## [0.5.1] - 2013-07-02

- `.js` suffix is now optional for in-browser specs


## [0.5.0] - 2013-06-30

- Add support for source-maps
- `opal` can now be used in the rails app generator: `rails new -j opal`
- migrate `#to_native` to the new signature: `#to_n`


## [0.4.0] - 2013-06-03

- Add `Rails.application.config.opal` which accepts:
    - method_missing: `<Boolean>` (default: `true`)
    - optimized_operators: `<Boolean>` (default: `true`)
    - arity_check: `<Boolean>` (default: `false`)
    - const_missing: `<Boolean>` (default: `true`)

- Add the Changelog


## [0.3.8] - 2013-05-07

- Add `opal/rails` alongside to `opal-rails` for older bundlers autorequire


## [0.3.7] - 2013-05-04

- Rails 4.0.0 support
- Add `opal_ujs`, now it's possible to use Opal for new Rails apps: `rails new <app-name> -j opal`
- Updated README examples

[0.9.0]: https://github.com/opal/opal-rails/compare/v0.8.1...HEAD
[0.8.1]: https://github.com/opal/opal-rails/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/opal/opal-rails/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/opal/opal-rails/compare/v0.6.3...v0.7.0
[0.6.3]: https://github.com/opal/opal-rails/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/opal/opal-rails/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/opal/opal-rails/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/opal/opal-rails/compare/v0.5.2...v0.6.0
[0.5.2]: https://github.com/opal/opal-rails/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/opal/opal-rails/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/opal/opal-rails/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/opal/opal-rails/compare/v0.3.8...v0.4.0
[0.3.8]: https://github.com/opal/opal-rails/compare/v0.3.7...v0.3.8
[0.3.7]: https://github.com/opal/opal-rails/compare/v0.3.6...v0.3.7
