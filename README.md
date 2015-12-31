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

Add your configuration in `config/application.rb` with the following contents:

```ruby
module MyApp
  class Application < Rails::Application
    # These are the available options with their default values

    # Compiler options
    config.opal.method_missing      = true
    config.opal.optimized_operators = true
    config.opal.arity_check         = false
    config.opal.const_missing       = true
    config.opal.dynamic_require_severity = :ignore

    # Enable/disable /opal_specs route
    config.opal.enable_specs = true

    # The path to opal specs from Rails.root
    config.opal.spec_location = 'spec-opal'
  end
end
```


## Usage


### Asset Pipeline

You can rename `app/assets/javascripts/application.js` to `application.js.rb`. Even if not necessary, it is recommended to change Sprockets' `//= require` statements to Ruby' `require` methods.
Sprockets' `//= require` statements won't be known by the opal builder and therefore you can end up adding something twice.

For Opal 0.8 and above, you have to use `application.js.rb` with the following syntax:

```ruby
# app/assets/javascripts/application.js.rb

require 'opal'
require 'opal_ujs'
require 'turbolinks'
require_tree '.'
```

If you want to use `application.js`, you need to `load` the Opal modules(files) manually, e.g.:

```
// application.js
//= require opal
//= require greeter
//= require_self
Opal.load('greeter');
```

As you see in the example above, Opal also gives you a Ruby equivalent of `//= require_tree`.

Opal requires are forwarded to the Asset Pipeline at compile time (similarly to what happens for RubyMotion). You can use either the `.rb` or `.opal` extension:

```ruby
# app/assets/javascripts/greeter.js.rb

puts "G'day world!" # check the console!

# Dom manipulation
require 'opal-jquery'

Document.ready? do
  Element.find('body > header').html = '<h1>Hi there!</h1>'
end
```




### As a template

You can use it for your views too, it even inherits instance and local variables from actions:

```ruby
# app/controllers/posts_controller.rb

def create
  @post = Post.create!(params[:post])
  render type: :js, locals: {comments_html: render_to_string(@post.comments)}
end
```

Each assign is filtered through JSON so it's reduced to basic types:

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

_Extracted to [`opal-rspec-rails`](https://github.com/opal/opal-rspec-rails)_

Add this line to your `Gemfile`

```ruby
gem 'opal-rspec-rails', github: 'opal/opal-rspec-rails'
```

### Minitest support

_Upcoming as `opal-minitest-rails`_


### Shared templates

As long as the templates are inside the sprockets/opal load path, then you should be able to just require them.

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

Just use `Opal.use_gem` in your asset initializer (in `config/initializers`).

Example:

```ruby
Opal.use_gem 'cannonbol'
```



## License

© 2012-2015 Elia Schito

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
