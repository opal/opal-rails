Rails.application.routes.draw do
  if %w[test development].include? Rails.env
    get '/opal_spec' => 'opal_spec#run'
    get '__opal_source_maps__/*path.js.map' => 'opal_source_maps#show'
  end
end
