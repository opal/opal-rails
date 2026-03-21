LAYOUT = <<~HTML
  <!DOCTYPE html>
  <html>
  <head><%= ActionController::Base.helpers.javascript_include_tag "application" %></head>
  <body><%= yield %></body>
  </html>
HTML

INDEX = <<~HTML
  <script type="text/ruby">
  puts 'hello from a script tag!'
  </script>
HTML

HAML = <<~HAML
  :opal
    $haml_filter = :working
HAML

WITH_ASSIGNMENTS = File.read "#{__dir__}/opal/with_assignments.js.rb"

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
  layout 'application'
  self.view_paths = [ActionView::FixtureResolver.new(
    'layouts/application.html.erb' => LAYOUT,
    'application/index.html.erb' => INDEX,
    'application/haml_filter.html.haml' => HAML,
    'application/with_assignments.js.opal' => WITH_ASSIGNMENTS
  )]

  def index; end

  def with_assignments
    object = Object.new
    def object.as_json(_options = {})
      { contents: 'json representation' }
    end

    @number_var = 1234
    @string_var = 'hello'
    @array_var  = [1, 'a']
    @hash_var   = { a: 1, b: 2 }
    @object_var = object

    render type: :js, locals: { local_var: 'i am local' }
  end

  def haml_filter; end
end

Rails.logger = Logger.new(STDOUT) if $DEBUG
