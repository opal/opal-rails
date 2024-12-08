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
- 1 spaces before normal text
 -->

## [2.0.4](https://github.com/opal/opal-rails/compare/v2.0.3...v2.0.4) - 2024-12-06

### Added

- Add Rails 7.1 & 7.2 support

## [2.0.3](https://github.com/opal/opal-rails/compare/v2.0.2...v2.0.3) - 2021-12-29

### Added

- Add HAML 6 support

## [2.0.2](https://github.com/opal/opal-rails/compare/v2.0.1...v2.0.2) - 2021-12-29


### Added

- Allow Rails 7


## [2.0.1](https://github.com/opal/opal-rails/compare/v2.0.0...v2.0.1) - 2021-03-03


### Added

- The install generator now will add an `opal.rb` initializer with a default compiler configuration and the template assign support disabled

### Fixed

- The install generator was missing a newline when changing the app layout


## [2.0.0](https://github.com/opal/opal-rails/compare/v1.1.2...v2.0.0) - 2021-02-23

*This is a major version, since a number of dependencies are going to be opt-in and support for older Rails
and Sprockets versions is dropped*

### Added

- Added support for Rails v6.1
- Added a generator for the initial setup (`bin/rails generate opal:install`) that will configure sprockets and create the main `application.js.rb`

### Changed

- Now the template handler will encode/decode local and instance variables with ActiveSupport::JSON

### Removed

- Removed support for Rails 5.x
- `opal-jquery` and `opal-activesupport` are no longer dependencies of `opal-rails`, if you need them you'll need to require and setup them manually


## [1.1.2](https://github.com/opal/opal-rails/compare/v1.1.1...v1.1.2) - 2019-09-26


### Fixed

- Default `skip_onload` to `true` when `javascript_asset_tag` is in debug mode, otherwise some assets may be loaded in the browser after the main source, thus being never loading by the Opal runtime.




## [1.1.1](https://github.com/opal/opal-rails/compare/v1.1.0...v1.1.1) - 2019-09-14


### Fixed

- Fix a problem with require order with regards to `opal-sprockets`.




## [1.1.0](https://github.com/opal/opal-rails/compare/v1.0.1...v1.1.0) - 2019-09-14


### Added

- Added the ability to pass only locals or only ivars when reproducing assigns in Opal templates, `Rails.application.config.opal.assigns_in_templates` can now be set to `:locals` or `:ivars` in addition to the already possible `true`.


### Changed

- The template handler now allows for the new Rails 6 api taking in both the template object and a source argument, but still allows the old behavior




## [1.0.1](https://github.com/opal/opal-rails/compare/v1.0.0...v1.0.1) - 2019-09-07


### Added

- Added support for Rails v6.0 (Sprockets)




## [1.0.0](https://github.com/opal/opal-rails/compare/v0.9.5...v1.0.0) - 2019-07-31


### Added

- Added support for Opal v1.0.0


### Removed

- Removed support for Opal v0.11
- Removed support for Rails v4.2 and v5.0
- Remove now unused code supporting the source-maps server which has been removed since Opal::Sprockets v0.4.2


### Fixed

- Allow Opal loading to run before the runtime, where previously would have ended up in an error
- A typo was preventing source-maps from being served on older versions of Opal




## [0.9.5](https://github.com/opal/opal-rails/compare/v0.9.4...v0.9.5) - 2018-09-07


### Added

- Added support for inline source-maps provided by opal-sprockets 0.4.2+
- Added Rails 5.2 to the test matrix


### Removed

- Removed support for Opal v0.10




## [0.9.4](https://github.com/opal/opal-rails/compare/v0.9.3...v0.9.4) - 2018-02-13


### Changed

- Improved documentation simplifying the basic usage example
- Allow Opal v0.11
- Improved testing




## [0.9.3](https://github.com/opal/opal-rails/compare/v0.9.2...v0.9.3) - 2017-05-08


### Added

- Support for async in `javascript_include_tag` by attaching Opal bootstrap code in the `onload` attribute instead of using a separate tag (the previous behaviour is still available by passing `force_opal_loader_tag: true` to `javascript_include_tag`).


### Changed

- `javascript_include_tag` no longer adds an extra javascript tag for the Opal bootstrapping code by default (See *Added* above).




## ~~[0.9.2] - 2017-04-22~~

*yanked: due to an error that prevented the generation of the loading code only in production*

### Added

- Added support for `sprockets-rails` v3




## [0.9.1] - 2016-11-30


### Added

- Added ability to disable passing local and instance variables to the Opal template handler by setting `Rails.application.config.opal.assigns_in_templates = false` in `config/initializers/assets.rb` (thanks to @lorefnon)
- Added dependency to `opal-sprockets` in preparation for Opal 0.11


### Changed

- Simplified the Opal file generated for a controller




## [0.9.0] - 2016-06-16


### Added

- Support for Opal 0.9
- Support for Rails 5.0


### Removed

- Removed support for Opal 0.8
- Extracted support for running spec to `opal-rspec-rails`, this is done to make its development independent of `opal-rails` and also to make room for the (yet to be implemented) `opal-minitest-rails`. In addition the extracted gem should address a number of issues like:
  - faster rake runs
  - allowing to use any sprockets processor (e.g. `opal-haml` templates were previously not supported)
  - nicer integration and customizability
- Drop support for Ruby 1.9.3




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




[0.9.2]: https://github.com/opal/opal-rails/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/opal/opal-rails/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/opal/opal-rails/compare/v0.8.1...v0.9.0
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
