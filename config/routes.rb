Rails.application.routes.draw do
  get '/get_agencies', :controller => 'api', :action => 'get_agencies'
  get '/get_routes/:name', controller: 'api', action: 'get_routes', as: :get_routes
  root to: "dest#index"
end
