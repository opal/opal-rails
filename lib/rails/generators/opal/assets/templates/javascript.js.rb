# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use Opal in this file: http://opalrb.org/
#
#
# Here's an example view class for your controller:
#
<% if namespaced? -%>
require <%= namespaced_file_path.to_s.inspect %>

<% end -%>
<% module_namespacing do -%>
class <%= class_name %>View
  # We should have <body class="controller-<%%= controller_name %>"> in layouts
  def initialize(selector = 'body.controller-<%= class_name.underscore %>')
    @selector = selector
  end

  def setup
    on(:click, 'a', &method(:link_clicked))
  end

  def link_clicked(event)
    event.prevent
    puts "Hello! (You just clicked on a link: #{event.current_target.text})"
  end


  private

  attr_reader :selector, :element

  # Look for elements in the scope of the base selector
  def find(selector)
    Element.find("#{@selector} #{selector}")
  end

  # Register events on document to save memory and be friends to Turbolinks
  def on(event, selector = nil, &block)
    Element[`document`].on(event, selector, &block)
  end
end

<%= class_name %>View.new.setup
<% end -%>
