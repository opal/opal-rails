# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use Opal in this file: http://opalrb.org/
#
#
# Here's an example view class for your controller:
#
<% if namespaced? -%>
#= require opal
#= require <%= namespaced_file_path %>

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>View
  def initialize(selector = 'body.controller-<%= controller_class_name.underscore %>', parent = Element)
    @element = parent.find(selector)
    setup
  end
  attr_reader :element

  # Put here the setup for
  def setup
    say_hello_when_a_link_is_clicked
  end

  def say_hello_when_a_link_is_clicked
    element.find('a') do |event|
      # Use prevent_default to stop default behavior (as you would do in jQuery)
      # event.prevent_default

      puts "Hello! (You just clicked on a link: #{event.current_target.text})"
    end
  end
end
<% end -%>
