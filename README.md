# Opal Rails

[![Build Status](https://secure.travis-ci.org/elia/opal-rails.png)](http://travis-ci.org/elia/opal-rails)
[![Code Climate](https://codeclimate.com/github/elia/opal-rails.png)](https://codeclimate.com/github/elia/opal-rails)
[![Gem Version](https://badge.fury.io/rb/opal-rails.png)](http://badge.fury.io/rb/opal-rails)
![fun guaranteed](http://b.repl.ca/v1/fun-guaranteed-brightgreen.png)

_Rails (3.2+, 4.0) bindings for [Opal Ruby](http://opalrb.org) engine. ([Changelog](https://github.com/opal/opal-rails/blob/master/CHANGELOG.md))_



## Installation

In your `Gemfile`

``` ruby
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
    # These are the available options with their default value:
    config.opal.method_missing      = true
    config.opal.optimized_operators = true
    config.opal.arity_check         = false
    config.opal.const_missing       = true
  end
end
```


### Gotchas

<del>After changing the version of the `opal` gem (e.g. via `bundle update opal`) or any configuration flag **you should trash the `#{Rails.root}/tmp/cache/assets` folder**, otherwise you could see a cached source compiled before the change.</del>

Now ships with a patch to sprockets cache key to include processor version that is also in this [pull request](https://github.com/sstephenson/sprockets/pull/508).



## Usage


### Asset Pipeline

```js
// app/assets/application.js.rb

//= require opal
//= require opal_ujs
//= require turbolinks
//= require_tree .
```

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


### Spec!

Add specs into `app/assets/javascripts/spec`:

and then a spec folder with you specs!

```ruby
# app/assets/javascripts/spec/example_spec.js.rb

describe 'a spec' do
  it 'has successful examples' do
    'I run'.should =~ /run/
  end
end
```

Then visit `/opal_spec` from your app and **reload at will**.

![1 examples, 0 failures](http://f.cl.ly/items/001n0V0g0u0v14160W2G/Schermata%2007-2456110%20alle%201.06.29%20am.png)


## License

© 2012-2013 Elia Schito

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
