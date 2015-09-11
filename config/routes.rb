Rails.application.routes.draw do
  get '/get_agencies', :controller => 'api', :action => 'get_agencies'
  get '/get_routes/:name', controller: 'api', action: 'get_routes', as: :get_routes
  get '/get_stops/:agency/:route(/:direction)', controller: 'api', action: 'get_stops', as: :get_stops
  get '/get_departures/:stop_code', controller: 'api', action: 'get_departures', as: :get_departures
  root to: "dest#index"
end
