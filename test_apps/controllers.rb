class ApplicationController < ActionController::Base

  include Rails.application.routes.url_helpers
  layout 'application'
  self.view_paths = [ActionView::FixtureResolver.new(
    'layouts/application.html.erb' => LAYOUT,
    'primary/index.html.erb' => INDEX,
    'primary/with_assignments.js.opal' => WITH_ASSIGNMENTS,
    'primary/without_assignments.js.opal' => WITH_ASSIGNMENTS,
    'secondary/without_assignments.js.opal' => WITH_ASSIGNMENTS
  )]

end

class PrimaryController < ApplicationController

  def assign_opal_instance_variables?
    params[:action] != 'without_assignments'
  end

  def index
  end

  def with_assignments
    object = Object.new
    def object.as_json options = {}
      {contents: 'json representation'}
    end

    @number_var = 1234
    @string_var = 'hello'
    @array_var  = [1,'a']
    @hash_var   = {a: 1, b: 2}
    @object_var = object

    render type: :js, locals: { local_var: 'i am local' }
  end

  def without_assignments
    @number_var = 1234
    @string_var = 'hello'
    @array_var  = [1,'a']
    @hash_var   = {a: 1, b: 2}

    render type: :js, locals: { local_var: 'i am local' }
  end

end

class SecondaryController < ApplicationController

  def assign_opal_instance_variables?
    false
  end

  def without_assignments
    @number_var = 1234
    @string_var = 'hello'
    @array_var  = [1,'a']
    @hash_var   = {a: 1, b: 2}

    render type: :js, locals: { local_var: 'i am local' }
  end

end
