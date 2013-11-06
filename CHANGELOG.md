# edge

# 0.6.1 2013-11-05

* Fix the rake task, now uses `opal-rspec` too


# 0.6.0 2013-11-05

* Don't load source maps if they're not enabled via `config.opal.source_map_enabled`
* Update to Opal v0.5.0
* Run in-browser specs with `opal-rspec`


# 0.5.2 2013-09-05

* Add `opal-activesupport` as a dependency
* Haml filter now is loaded inside the railtie initializer, avoiding potential Gemfile ordering issues
* Add the `rake opal:spec` task to run browser specs from the terminal (requires phantomjs)


# 0.5.1 2013-07-02

* `.js` suffix is now optional for in-browser specs


# 0.5.0 2013-06-30

* Add support for source-maps
* `opal` can now be used in the rails app generator: `rails new -j opal`
* migrate `#to_native` to the new signature: `#to_n`


# 0.4.0 2013-06-03

* Add `Rails.application.config.opal` which accepts:
    - method_missing: `<Boolean>` (default: `true`)
    - optimized_operators: `<Boolean>` (default: `true`)
    - arity_check: `<Boolean>` (default: `false`)
    - const_missing: `<Boolean>` (default: `true`)

* Add the Changelog


# 0.3.8 2013-05-07

* Add `opal/rails` alongside to `opal-rails` for older bundlers autorequire


# 0.3.7 2013-05-04

* Rails 4.0.0 support
* Add `opal_ujs`, now it's possible to use Opal for new Rails apps: `rails new <app-name> -j opal`
* Updated README examples

