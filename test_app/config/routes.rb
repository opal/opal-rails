TestApp::Application.routes.draw do
  get 'application/with_assignments' => 'application#with_assignments'
  root :to => 'application#index'
end
