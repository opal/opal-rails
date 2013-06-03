# edge

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

