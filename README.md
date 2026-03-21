# Opal Rails

[![Build Status](https://github.com/opal/opal-rails/actions/workflows/build.yml/badge.svg)](https://github.com/opal/opal-rails/actions/workflows/build.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/31dda24adcecb836348f/maintainability)](https://codeclimate.com/github/opal/opal-rails/maintainability)
[![Gem Version](https://badge.fury.io/rb/opal-rails.svg)](http://badge.fury.io/rb/opal-rails)
![fun guaranteed](https://img.shields.io/badge/fun-guaranteed-brightgreen.svg)
![web scale](http://img.shields.io/badge/webscale-over%209000-green.svg)

_Rails bindings for [Opal](http://opalrb.com). ([Changelog](https://github.com/opal/opal-rails/blob/master/CHANGELOG.md))_

## Installation

In your `Gemfile`

```ruby
gem 'opal-rails'
```

This branch targets Rails 7.0 through 7.2. Rails 6.x is no longer supported in the build-first workflow.

Run the `opal:install` Rails generator to create a build-based Opal setup:

```
bin/rails g opal:install
```

The generator now creates:

- `app/opal/application.rb` for greenfield apps, or reuses `app/assets/opal` when migrating an older layout
- `config/initializers/opal.rb` with build-oriented defaults
- `app/assets/builds/.keep`
- a `Procfile.dev` entry for `opal: bin/rails opal:watch`
- a `bin/dev` launcher when the app does not already have one

If the generator finds an existing multi-entrypoint Opal source root, it keeps that layout intact, configures `config.opal.entrypoints = :all`, and avoids inserting a default `javascript_include_tag "application"` when no `application.rb` entrypoint exists.

If the host app already has a non-Opal `application.js`, the generator keeps `app/opal/application.rb` as the source file but configures the built logical asset name as `opal` so the two pipelines do not collide.

It no longer edits `app/assets/config/manifest.js`.
It no longer depends on `opal-sprockets` or a Sprockets-specific helper loader at runtime.
The `opal:assets` generator now writes plain `.rb` files into the active Opal source root instead of generating `app/assets/javascripts/*.js.rb` files.


### Configuration

#### For the compiler

The following automatically gets added to your configuration for the compiler when running the `opal:install` Rails generator:

`config/initializers/opal.rb`

```ruby
# Compiler options
Rails.application.configure do
  config.opal.method_missing_enabled   = true
  config.opal.const_missing_enabled    = true
  config.opal.arity_check_enabled      = true
  config.opal.freezing_stubs_enabled   = true
  config.opal.dynamic_require_severity = :ignore
end
```

Check out the full list of the available configuration options at: [lib/opal/config.rb](https://github.com/opal/opal/blob/master/lib/opal/config.rb).

### Build-based assets

`opal-rails` now also exposes an explicit build task for modern Rails-style asset generation.

The host Rails app is still responsible for choosing an asset server such as Propshaft or Sprockets to serve the built files from `app/assets/builds`.

Current build-oriented config keys are:

```ruby
Rails.application.configure do
  config.opal.source_path = Rails.root.join('app/opal')
  config.opal.entrypoints_path = config.opal.source_path
  config.opal.build_path = Rails.root.join('app/assets/builds')
  config.opal.entrypoints = { 'application' => 'application.rb' }
  config.opal.append_paths = []
  config.opal.use_gems = []
end
```

For mixed-stack apps that already use another `application.js`, use an explicit logical name for the Opal output instead of colliding with the existing asset:

```ruby
Rails.application.configure do
  config.opal.source_path = Rails.root.join('app/opal')
  config.opal.entrypoints_path = config.opal.source_path
  config.opal.entrypoints = { 'opal' => 'application.rb' }
end
```

With that in place, you can build Opal entrypoints into browser-ready assets with:

```bash
bin/rails opal:build
```

`opal-rails` also hooks `opal:build` into `assets:precompile` automatically, and into `test:prepare` / `spec:prepare` when those tasks exist in the host app.

And clean only Opal-owned build outputs with:

```bash
bin/rails opal:clobber
```

To rebuild entrypoints while you develop, run:

```bash
bin/rails opal:watch
```

This writes `*.js` outputs, optional `*.js.map` files, and an Opal-owned manifest into `app/assets/builds`.

`opal:clobber` uses that manifest to remove only Opal-tracked outputs, leaving unrelated assets in `app/assets/builds` alone.

`opal:watch` uses the `listen` gem, tracks Opal/core and app dependency files, rebuilds affected entrypoints for known file changes, and falls back to a full rebuild when files are added or removed.

Any directories listed in `config.opal.append_paths` are also part of that watch scope, so shared templates or support files can trigger rebuilds too.

Include the built entrypoint in your layout with the normal Rails helper:

```erb
<%= javascript_include_tag "application", "data-turbo-track": "reload" %>
```

Boot code should live in the built Opal entrypoint itself rather than in a helper-side loader shim.

If you are migrating an app that already keeps frontend Ruby under `app/assets/opal`, set `config.opal.source_path` and `config.opal.entrypoints_path` to that directory instead. If your asset server would otherwise expose raw files from that directory, exclude it in the host app configuration yourself. For example, Propshaft apps can add `config.assets.excluded_paths << Rails.root.join('app/assets/opal')`. Apps using the default `app/opal` layout do not need this.

For the default `app/opal` layout, `opal-rails` also ignores that source root in Rails autoloaders so frontend Opal files are not treated as application constants.

If you want one built asset per top-level Opal file, you can opt into bulk entrypoint discovery:

```ruby
Rails.application.configure do
  config.opal.source_path = Rails.root.join('app/assets/opal')
  config.opal.entrypoints_path = config.opal.source_path
  config.opal.entrypoints = :all
end
```

In `:all` mode, `opal-rails` compiles each top-level `*.rb` file in `entrypoints_path` to a same-name asset in `app/assets/builds`, ignores nested support files, and prunes stale Opal-owned outputs when an entrypoint file disappears.

The install generator will choose that `:all` configuration automatically for migration-friendly layouts that already have multiple top-level Opal entrypoints.

If you want to generate a controller-specific Opal file, use:

```bash
bin/rails g opal:assets dashboard
```

This now creates `app/opal/dashboard.rb` by default, or `app/assets/opal/dashboard.rb` for migration-friendly layouts.

The bundled test app and integration suite prebuild assets from `app/opal` into `app/assets/builds` instead of relying on `app/assets/javascripts/*.js.rb` request-time compilation.

#### For template assigns

You may optionally add configuration for rendering assigns when using the template handler from actions:

`config/initializers/opal.rb`

```ruby
Rails.application.configure do
  # ...
  config.opal.assigns_in_templates = true
  config.opal.assigns_in_templates = :locals # only locals
  config.opal.assigns_in_templates = :ivars # only instance variables
end
```


Local and instance variables will be sent down to the view after converting their values to JSON.


## Usage

### Basic example

#### Rails 7 example

This example assumes Rails 7 and having followed the [Installation](#installation) instructions.

1- Delete `app/javascript/application.js`

2- Enable the following lines in the generated `app/opal/application.rb` below `require "opal"`:

```ruby
puts "hello world!"
require "native"
$$[:document].addEventListener :DOMContentLoaded do
  $$[:document][:body][:innerHTML] = '<h2>Hello World!</h2>'
end
```

3- Run `rails g scaffold welcome`

4- Run `rails db:migrate`

5- Clear `app/views/welcomes/index.html.erb` (empty its content)

6- Run `bin/rails opal:build`

7- Run `rails s`

8- Visit `http://localhost:3000/welcomes`

In the browser webpage, you should see:

<h2>Hello World!</h2>

Also, you should see `hello world!` in the browser console.

#### Migrating older Sprockets-style apps

Older `opal-rails` apps often used `app/assets/javascripts/application.js.rb`, `manifest.js`, and request-time Sprockets compilation.

The build-first migration path is:

1. move the Opal entrypoint to `app/opal/application.rb` or keep `app/assets/opal/application.rb` for migration-friendly layouts;
2. configure `config.opal.source_path`, `config.opal.entrypoints_path`, and `config.opal.entrypoints` in `config/initializers/opal.rb`;
3. build with `bin/rails opal:build` and watch with `bin/rails opal:watch`;
4. include the built asset with the normal `javascript_include_tag` helper.

The documented path no longer relies on Sprockets directives such as `require_tree` or on helper-level Opal loader injection.

If the host app itself still uses Sprockets during migration, it can keep the minimal manifest entries needed to serve the built files, but `opal-rails` itself no longer requires `opal-sprockets` to compile or boot Opal assets.


### As a template

You can use it for your views too:

```ruby
# app/controllers/posts_controller.rb

def create
  @post = Post.create!(params[:post])
  render type: :js, locals: {comments_html: render_to_string(@post.comments)}
end
```

Assigned instance that would normally be available in your views are converted to JSON objects first.

```ruby
# app/views/posts/create.js.opal

post = Element.find('.post')
post.find('.title').html    = @post[:title]
post.find('.body').html     = @post[:body]
post.find('.comments').html = comments_html
```

#### Instance and local variables in templates

By default `opal-rails`, will NOT forward any instance and local variable you'll pass to the template.

This behavior can be enabled by setting `Rails.application.config.opal.assigns_in_templates` to `true` in `config/initializers/opal.rb`:

```ruby
Rails.application.configure do
  # ...
  config.opal.assigns_in_templates = true
  # ...
end
```



### As a Haml filter (optional)

Of course you need to require `haml-rails` separately since its presence is not assumed

```haml
-# app/views/posts/show.html.haml

%article.post
  %h1.title= post.title
  .body= post.body

%a#show-comments Display Comments!

.comments(style="display:none;")
  - post.comments.each do |comment|
    .comment= comment.body

:opal
  Document.ready? do
    Element.find('#show-comments').on :click do |click|
      click.prevent_default
      click.current_target.hide
      Element.find('.comments').effect(:fade_in)
    end
  end
```


### RSpec support

_Extracted to (unreleased) [`opal-rspec-rails`](https://github.com/opal/opal-rspec-rails)_

Add this line to your `Gemfile`:

```ruby
gem 'opal-rspec-rails', github: 'opal/opal-rspec-rails'
```


### Minitest support

_Upcoming as `opal-minitest-rails`_


### Shared templates

As long as the templates are inside an Opal load path, you should be able to require them.

Let's say we have this template `app/views/shared/test.haml`:

```haml
.row
  .col-sm-12
    = @bar
```

We need to make sure Opal can see and compile that template. Add the path to `config.opal.append_paths`:

```ruby
# config/initializers/opal.rb
Rails.application.config.opal.append_paths << Rails.root.join('app', 'views', 'shared')
```

Now, somewhere in `application.rb` you need to require that template, and you can just run it through `Template`:

```ruby
# app/opal/application.rb
require 'opal'
require 'opal-haml'
require 'test'

@bar = "hello world"

template = Template['test']
template.render(self)
# =>  '<div class="row"><div class="col-sm-12">hello world</div></div>'
```


### Using Ruby gems from Opal

Add gems to the Opal load path from `config/initializers/opal.rb`.

Example:

```ruby
Rails.application.config.opal.use_gems << 'cannonbol'
```


## Contributing

Run the specs:

```
bin/setup
bin/rake
```

Inspect the test app:

```
bin/rackup
# visit localhost:9292
```

Tinker with a sandbox app:

```
bin/sandbox # will re-create the app
bin/rails s # will start the sandbox app server
# visit localhost:3000
```


## License

© 2012-2024 Elia Schito

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
