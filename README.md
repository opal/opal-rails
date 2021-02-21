# Opal Rails

[![Build Status](https://github.com/opal/opal-rails/workflows/CI/badge.svg)](https://github.com/opal/opal-rails/actions)
[![Maintainability](https://api.codeclimate.com/v1/badges/31dda24adcecb836348f/maintainability)](https://codeclimate.com/github/opal/opal-rails/maintainability)
[![Gem Version](https://badge.fury.io/rb/opal-rails.svg)](http://badge.fury.io/rb/opal-rails)
![fun guaranteed](https://img.shields.io/badge/fun-guaranteed-brightgreen.svg)
![web scale](http://img.shields.io/badge/webscale-over%209000-green.svg)

_Rails bindings for [Opal](http://opalrb.com). ([Changelog](https://github.com/opal/opal-rails/blob/master/CHANGELOG.md))_

### Looking for Webpack support? 👀

If you want to integrate Opal via Webpack please refer to [opal-webpack-loader](https://github.com/isomorfeus/opal-webpack-loader#installation) installation instructions.

ℹ️ Webpack and ES6 modules are not yet officially supported, but we're working on it thanks to the awesome work done in _opal-webpack-loader_.


## Installation

In your `Gemfile`

```ruby
gem 'opal-rails'
```

Add `app/assets/javascript` to your asset-pipeline manifest in `app/assets/config/manifest.js`:

```
bin/rails opal:install
```


### Configuration

Add your configuration in `config/initializers/assets.rb` with the following contents:

```ruby
# Compiler options
Rails.application.config.opal.method_missing           = true
Rails.application.config.opal.optimized_operators      = true
Rails.application.config.opal.arity_check              = !Rails.env.production?
Rails.application.config.opal.const_missing            = true
Rails.application.config.opal.dynamic_require_severity = :ignore

# Other options

# Send local and instance variables down to the view after converting
# thier value with `.to_json`
Rails.application.config.opal.assigns_in_templates = true
Rails.application.config.opal.assigns_in_templates = :locals # only locals
Rails.application.config.opal.assigns_in_templates = :ivars # only instance variables
```

For a full list of the available configuration options for the compiler please refer to: [lib/opal/config.rb](https://github.com/opal/opal/blob/master/lib/opal/config.rb).



## Usage

### Basic example

1. Rename `app/assets/javascripts/application.js` to `app/assets/javascripts/application.js.rb`
2. Replace the Sprockets directives with plain requires

```ruby
# Require the opal runtime and core library
require 'opal'

# For Rails 5.1 and above, otherwise use 'opal_ujs'
require 'rails_ujs'

# Require of JS libraries will be forwarded to sprockets as is
require 'turbolinks'

# a Ruby equivalent of the require_tree Sprockets directive is available
require_tree '.'

puts "hello world!"
```

### A more extensive example

```ruby
require 'opal'
require 'opal_ujs'
require 'turbolinks'
require_tree '.' # a Ruby equivalent of the require_tree Sprockets directive is available

# ---- YOUR FANCY RUBY CODE HERE ----
#
# Examples:

# == Print something in the browser's console
puts "Hello world!"
pp hello: :world
require 'console'
$console.log %w[Hello world!]

# == Use Native to wrap native JS objects, $$ is preconfigured to wrap `window`
require 'native'
$$.alert "Hello world!"

# == Do some DOM manipulation with jQuery
require 'opal-jquery'
Document.ready? do
  Element.find('body').html = '<h1>Hello world!</h1>'
end

# == Or access the DOM api directly
$$[:document].addEventListener(:DOMContentLoaded, -> {
  $$[:document].querySelector('body')[:innerHTML] = '<h1>Hello world!</h1>'
})

```


### Using Sprockets directives and `application.js`

If you want to use `application.js` (instead of `application.js.rb`) and keep using Sprockets directives, you'll need to load the Opal files you require via Sprockets manually, e.g.:

```js
//= require opal
//= require rails_ujs
//= require turbolinks
//= require_tree .
//= require app

Opal.require('opal');
Opal.require('app');
```


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

By default `opal-rails` will forward any instance and local variable you'll pass to the template.

This behavior can be disabled by setting `Rails.application.config.opal.assigns_in_templates` to `false` in `config/initializers/assets.rb`:

```ruby
Rails.application.config.opal.assigns_in_templates = false
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

As long as the templates are inside the Sprockets/Opal load path, then you should be able to just require them.

Let's say we have this template `app/views/shared/test.haml`:

```haml
.row
  .col-sm-12
    = @bar
```

We need to make sure Opal can see and compile that template. So we need to add the path to sprockets:

```ruby
# config/initializers/opal.rb
Rails.application.config.assets.paths << Rails.root.join('app', 'views', 'shared').to_s
```

Now, somewhere in `application.rb` you need to require that template, and you can just run it through `Template`:

```ruby
# app/assets/javascripts/application.rb
require 'opal'
require 'opal-haml'
require 'test'

@bar = "hello world"

template = Template['test']
template.render(self)
# =>  '<div class="row"><div class="col-sm-12">hello world</div></div>'
```


### Using Ruby gems from Opal

Just use `Opal.use_gem` in your asset initializer (`config/initializers/assets.rb`).

Example:

```ruby
Opal.use_gem 'cannonbol'
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

© 2012-2019 Elia Schito

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
