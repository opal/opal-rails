# Opal Rails

[![Build Status](https://secure.travis-ci.org/opal/opal-rails.svg)](http://travis-ci.org/opal/opal-rails)
[![Code Climate](https://img.shields.io/codeclimate/github/opal/opal-rails.svg)](https://codeclimate.com/github/opal/opal-rails)
[![Gem Version](https://badge.fury.io/rb/opal-rails.svg)](http://badge.fury.io/rb/opal-rails)
![fun guaranteed](https://img.shields.io/badge/fun-guaranteed-brightgreen.svg)
![web scale](http://img.shields.io/badge/webscale-over%209000-green.svg)

_Rails bindings for [Opal Ruby](http://opalrb.org) engine. ([Changelog](https://github.com/opal/opal-rails/blob/master/CHANGELOG.md))_



## Installation

In your `Gemfile`

```ruby
gem 'opal-rails'
```

or when you build your new Rails app:

```bash
rails new <app-name> --javascript=opal
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
```

For a full list of the available configuration options please refer to: [lib/opal/config.rb](https://github.com/opal/opal/blob/master/lib/opal/config.rb).



## Usage

Rename `app/assets/javascripts/application.js` to `app/assets/javascripts/application.js.rb` and 
replace the Sprockets directives with plain requires as follows:

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


### Using Sprockets directives

If you want to use `application.js` (instead of `application.js.rb`) and keep Sprockets directives, you'll need to load the Opal files you require via Sprockets manually, e.g.:

```
//= require opal
//= require opal_ujs
//= require turbolinks
//= require_tree .
//= require foobar

Opal.load('foobar');
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



## License

© 2012-2016 Elia Schito

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
